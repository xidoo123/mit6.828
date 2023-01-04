
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;
	// cprintf("[%p]\n", umain);
	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 e0 1d 80 00       	push   $0x801de0
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 9c 0a 00 00       	call   800af6 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;
	// cprintf("[%p]\n", umain);
	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 00 1e 80 00       	push   $0x801e00
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
umain(int argc, char **argv)
{
	int i;
	// cprintf("[%p]\n", umain);
	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 40 80 00       	mov    0x804004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 2c 1e 80 00       	push   $0x801e2c
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 2d 0a 00 00       	call   800ad7 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 e6 0d 00 00       	call   800ed1 <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 a1 09 00 00       	call   800a96 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 2f 09 00 00       	call   800a59 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 54 01 00 00       	call   8002c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 d4 08 00 00       	call   800a59 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c8:	39 d3                	cmp    %edx,%ebx
  8001ca:	72 05                	jb     8001d1 <printnum+0x30>
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 45                	ja     800216 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 4b 19 00 00       	call   801b40 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 18                	jmp    800220 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb 03                	jmp    800219 <printnum+0x78>
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f e8                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 38 1a 00 00       	call   801c70 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 55 1e 80 00 	movsbl 0x801e55(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800253:	83 fa 01             	cmp    $0x1,%edx
  800256:	7e 0e                	jle    800266 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	8b 52 04             	mov    0x4(%edx),%edx
  800264:	eb 22                	jmp    800288 <getuint+0x38>
	else if (lflag)
  800266:	85 d2                	test   %edx,%edx
  800268:	74 10                	je     80027a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
  800278:	eb 0e                	jmp    800288 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800290:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800294:	8b 10                	mov    (%eax),%edx
  800296:	3b 50 04             	cmp    0x4(%eax),%edx
  800299:	73 0a                	jae    8002a5 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	88 02                	mov    %al,(%edx)
}
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b0:	50                   	push   %eax
  8002b1:	ff 75 10             	pushl  0x10(%ebp)
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	ff 75 08             	pushl  0x8(%ebp)
  8002ba:	e8 05 00 00 00       	call   8002c4 <vprintfmt>
	va_end(ap);
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 2c             	sub    $0x2c,%esp
  8002cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d6:	eb 12                	jmp    8002ea <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	0f 84 89 03 00 00    	je     800669 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	53                   	push   %ebx
  8002e4:	50                   	push   %eax
  8002e5:	ff d6                	call   *%esi
  8002e7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ea:	83 c7 01             	add    $0x1,%edi
  8002ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e2                	jne    8002d8 <vprintfmt+0x14>
  8002f6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002fa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800301:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800308:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 07                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800319:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8d 47 01             	lea    0x1(%edi),%eax
  800320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800323:	0f b6 07             	movzbl (%edi),%eax
  800326:	0f b6 c8             	movzbl %al,%ecx
  800329:	83 e8 23             	sub    $0x23,%eax
  80032c:	3c 55                	cmp    $0x55,%al
  80032e:	0f 87 1a 03 00 00    	ja     80064e <vprintfmt+0x38a>
  800334:	0f b6 c0             	movzbl %al,%eax
  800337:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800341:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800345:	eb d6                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034a:	b8 00 00 00 00       	mov    $0x0,%eax
  80034f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800352:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800355:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800359:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80035c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035f:	83 fa 09             	cmp    $0x9,%edx
  800362:	77 39                	ja     80039d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800364:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800367:	eb e9                	jmp    800352 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 48 04             	lea    0x4(%eax),%ecx
  80036f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800372:	8b 00                	mov    (%eax),%eax
  800374:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037a:	eb 27                	jmp    8003a3 <vprintfmt+0xdf>
  80037c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037f:	85 c0                	test   %eax,%eax
  800381:	b9 00 00 00 00       	mov    $0x0,%ecx
  800386:	0f 49 c8             	cmovns %eax,%ecx
  800389:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038f:	eb 8c                	jmp    80031d <vprintfmt+0x59>
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800394:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039b:	eb 80                	jmp    80031d <vprintfmt+0x59>
  80039d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a7:	0f 89 70 ff ff ff    	jns    80031d <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ba:	e9 5e ff ff ff       	jmp    80031d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003bf:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c5:	e9 53 ff ff ff       	jmp    80031d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d3:	83 ec 08             	sub    $0x8,%esp
  8003d6:	53                   	push   %ebx
  8003d7:	ff 30                	pushl  (%eax)
  8003d9:	ff d6                	call   *%esi
			break;
  8003db:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e1:	e9 04 ff ff ff       	jmp    8002ea <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	99                   	cltd   
  8003f2:	31 d0                	xor    %edx,%eax
  8003f4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f6:	83 f8 0f             	cmp    $0xf,%eax
  8003f9:	7f 0b                	jg     800406 <vprintfmt+0x142>
  8003fb:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  800402:	85 d2                	test   %edx,%edx
  800404:	75 18                	jne    80041e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800406:	50                   	push   %eax
  800407:	68 6d 1e 80 00       	push   $0x801e6d
  80040c:	53                   	push   %ebx
  80040d:	56                   	push   %esi
  80040e:	e8 94 fe ff ff       	call   8002a7 <printfmt>
  800413:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800419:	e9 cc fe ff ff       	jmp    8002ea <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80041e:	52                   	push   %edx
  80041f:	68 5a 22 80 00       	push   $0x80225a
  800424:	53                   	push   %ebx
  800425:	56                   	push   %esi
  800426:	e8 7c fe ff ff       	call   8002a7 <printfmt>
  80042b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800431:	e9 b4 fe ff ff       	jmp    8002ea <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800441:	85 ff                	test   %edi,%edi
  800443:	b8 66 1e 80 00       	mov    $0x801e66,%eax
  800448:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044f:	0f 8e 94 00 00 00    	jle    8004e9 <vprintfmt+0x225>
  800455:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800459:	0f 84 98 00 00 00    	je     8004f7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	ff 75 d0             	pushl  -0x30(%ebp)
  800465:	57                   	push   %edi
  800466:	e8 86 02 00 00       	call   8006f1 <strnlen>
  80046b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046e:	29 c1                	sub    %eax,%ecx
  800470:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800473:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800476:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800480:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	eb 0f                	jmp    800493 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 ef 01             	sub    $0x1,%edi
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 ff                	test   %edi,%edi
  800495:	7f ed                	jg     800484 <vprintfmt+0x1c0>
  800497:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80049d:	85 c9                	test   %ecx,%ecx
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	0f 49 c1             	cmovns %ecx,%eax
  8004a7:	29 c1                	sub    %eax,%ecx
  8004a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b2:	89 cb                	mov    %ecx,%ebx
  8004b4:	eb 4d                	jmp    800503 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ba:	74 1b                	je     8004d7 <vprintfmt+0x213>
  8004bc:	0f be c0             	movsbl %al,%eax
  8004bf:	83 e8 20             	sub    $0x20,%eax
  8004c2:	83 f8 5e             	cmp    $0x5e,%eax
  8004c5:	76 10                	jbe    8004d7 <vprintfmt+0x213>
					putch('?', putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 0c             	pushl  0xc(%ebp)
  8004cd:	6a 3f                	push   $0x3f
  8004cf:	ff 55 08             	call   *0x8(%ebp)
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	eb 0d                	jmp    8004e4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	52                   	push   %edx
  8004de:	ff 55 08             	call   *0x8(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e4:	83 eb 01             	sub    $0x1,%ebx
  8004e7:	eb 1a                	jmp    800503 <vprintfmt+0x23f>
  8004e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f5:	eb 0c                	jmp    800503 <vprintfmt+0x23f>
  8004f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800500:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800503:	83 c7 01             	add    $0x1,%edi
  800506:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050a:	0f be d0             	movsbl %al,%edx
  80050d:	85 d2                	test   %edx,%edx
  80050f:	74 23                	je     800534 <vprintfmt+0x270>
  800511:	85 f6                	test   %esi,%esi
  800513:	78 a1                	js     8004b6 <vprintfmt+0x1f2>
  800515:	83 ee 01             	sub    $0x1,%esi
  800518:	79 9c                	jns    8004b6 <vprintfmt+0x1f2>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	eb 18                	jmp    80053c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	53                   	push   %ebx
  800528:	6a 20                	push   $0x20
  80052a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052c:	83 ef 01             	sub    $0x1,%edi
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	eb 08                	jmp    80053c <vprintfmt+0x278>
  800534:	89 df                	mov    %ebx,%edi
  800536:	8b 75 08             	mov    0x8(%ebp),%esi
  800539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053c:	85 ff                	test   %edi,%edi
  80053e:	7f e4                	jg     800524 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800540:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800543:	e9 a2 fd ff ff       	jmp    8002ea <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800548:	83 fa 01             	cmp    $0x1,%edx
  80054b:	7e 16                	jle    800563 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 08             	lea    0x8(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 50 04             	mov    0x4(%eax),%edx
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800561:	eb 32                	jmp    800595 <vprintfmt+0x2d1>
	else if (lflag)
  800563:	85 d2                	test   %edx,%edx
  800565:	74 18                	je     80057f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	89 c1                	mov    %eax,%ecx
  800577:	c1 f9 1f             	sar    $0x1f,%ecx
  80057a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057d:	eb 16                	jmp    800595 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 50 04             	lea    0x4(%eax),%edx
  800585:	89 55 14             	mov    %edx,0x14(%ebp)
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058d:	89 c1                	mov    %eax,%ecx
  80058f:	c1 f9 1f             	sar    $0x1f,%ecx
  800592:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800595:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800598:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a4:	79 74                	jns    80061a <vprintfmt+0x356>
				putch('-', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 2d                	push   $0x2d
  8005ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b4:	f7 d8                	neg    %eax
  8005b6:	83 d2 00             	adc    $0x0,%edx
  8005b9:	f7 da                	neg    %edx
  8005bb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005be:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c3:	eb 55                	jmp    80061a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c8:	e8 83 fc ff ff       	call   800250 <getuint>
			base = 10;
  8005cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d2:	eb 46                	jmp    80061a <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d7:	e8 74 fc ff ff       	call   800250 <getuint>
			base = 8;
  8005dc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e1:	eb 37                	jmp    80061a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 30                	push   $0x30
  8005e9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005eb:	83 c4 08             	add    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	6a 78                	push   $0x78
  8005f1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800603:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800606:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060b:	eb 0d                	jmp    80061a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060d:	8d 45 14             	lea    0x14(%ebp),%eax
  800610:	e8 3b fc ff ff       	call   800250 <getuint>
			base = 16;
  800615:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061a:	83 ec 0c             	sub    $0xc,%esp
  80061d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800621:	57                   	push   %edi
  800622:	ff 75 e0             	pushl  -0x20(%ebp)
  800625:	51                   	push   %ecx
  800626:	52                   	push   %edx
  800627:	50                   	push   %eax
  800628:	89 da                	mov    %ebx,%edx
  80062a:	89 f0                	mov    %esi,%eax
  80062c:	e8 70 fb ff ff       	call   8001a1 <printnum>
			break;
  800631:	83 c4 20             	add    $0x20,%esp
  800634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800637:	e9 ae fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	51                   	push   %ecx
  800641:	ff d6                	call   *%esi
			break;
  800643:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800649:	e9 9c fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 25                	push   $0x25
  800654:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb 03                	jmp    80065e <vprintfmt+0x39a>
  80065b:	83 ef 01             	sub    $0x1,%edi
  80065e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800662:	75 f7                	jne    80065b <vprintfmt+0x397>
  800664:	e9 81 fc ff ff       	jmp    8002ea <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800669:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066c:	5b                   	pop    %ebx
  80066d:	5e                   	pop    %esi
  80066e:	5f                   	pop    %edi
  80066f:	5d                   	pop    %ebp
  800670:	c3                   	ret    

00800671 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	83 ec 18             	sub    $0x18,%esp
  800677:	8b 45 08             	mov    0x8(%ebp),%eax
  80067a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800680:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800684:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800687:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068e:	85 c0                	test   %eax,%eax
  800690:	74 26                	je     8006b8 <vsnprintf+0x47>
  800692:	85 d2                	test   %edx,%edx
  800694:	7e 22                	jle    8006b8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800696:	ff 75 14             	pushl  0x14(%ebp)
  800699:	ff 75 10             	pushl  0x10(%ebp)
  80069c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069f:	50                   	push   %eax
  8006a0:	68 8a 02 80 00       	push   $0x80028a
  8006a5:	e8 1a fc ff ff       	call   8002c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 05                	jmp    8006bd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c8:	50                   	push   %eax
  8006c9:	ff 75 10             	pushl  0x10(%ebp)
  8006cc:	ff 75 0c             	pushl  0xc(%ebp)
  8006cf:	ff 75 08             	pushl  0x8(%ebp)
  8006d2:	e8 9a ff ff ff       	call   800671 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	eb 03                	jmp    8006e9 <strlen+0x10>
		n++;
  8006e6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ed:	75 f7                	jne    8006e6 <strlen+0xd>
		n++;
	return n;
}
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ff:	eb 03                	jmp    800704 <strnlen+0x13>
		n++;
  800701:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800704:	39 c2                	cmp    %eax,%edx
  800706:	74 08                	je     800710 <strnlen+0x1f>
  800708:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80070c:	75 f3                	jne    800701 <strnlen+0x10>
  80070e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	53                   	push   %ebx
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	83 c2 01             	add    $0x1,%edx
  800721:	83 c1 01             	add    $0x1,%ecx
  800724:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800728:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072b:	84 db                	test   %bl,%bl
  80072d:	75 ef                	jne    80071e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80072f:	5b                   	pop    %ebx
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	53                   	push   %ebx
  800736:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800739:	53                   	push   %ebx
  80073a:	e8 9a ff ff ff       	call   8006d9 <strlen>
  80073f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	01 d8                	add    %ebx,%eax
  800747:	50                   	push   %eax
  800748:	e8 c5 ff ff ff       	call   800712 <strcpy>
	return dst;
}
  80074d:	89 d8                	mov    %ebx,%eax
  80074f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	8b 75 08             	mov    0x8(%ebp),%esi
  80075c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075f:	89 f3                	mov    %esi,%ebx
  800761:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800764:	89 f2                	mov    %esi,%edx
  800766:	eb 0f                	jmp    800777 <strncpy+0x23>
		*dst++ = *src;
  800768:	83 c2 01             	add    $0x1,%edx
  80076b:	0f b6 01             	movzbl (%ecx),%eax
  80076e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800771:	80 39 01             	cmpb   $0x1,(%ecx)
  800774:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800777:	39 da                	cmp    %ebx,%edx
  800779:	75 ed                	jne    800768 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077b:	89 f0                	mov    %esi,%eax
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	56                   	push   %esi
  800785:	53                   	push   %ebx
  800786:	8b 75 08             	mov    0x8(%ebp),%esi
  800789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078c:	8b 55 10             	mov    0x10(%ebp),%edx
  80078f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800791:	85 d2                	test   %edx,%edx
  800793:	74 21                	je     8007b6 <strlcpy+0x35>
  800795:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800799:	89 f2                	mov    %esi,%edx
  80079b:	eb 09                	jmp    8007a6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079d:	83 c2 01             	add    $0x1,%edx
  8007a0:	83 c1 01             	add    $0x1,%ecx
  8007a3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a6:	39 c2                	cmp    %eax,%edx
  8007a8:	74 09                	je     8007b3 <strlcpy+0x32>
  8007aa:	0f b6 19             	movzbl (%ecx),%ebx
  8007ad:	84 db                	test   %bl,%bl
  8007af:	75 ec                	jne    80079d <strlcpy+0x1c>
  8007b1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b6:	29 f0                	sub    %esi,%eax
}
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c5:	eb 06                	jmp    8007cd <strcmp+0x11>
		p++, q++;
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cd:	0f b6 01             	movzbl (%ecx),%eax
  8007d0:	84 c0                	test   %al,%al
  8007d2:	74 04                	je     8007d8 <strcmp+0x1c>
  8007d4:	3a 02                	cmp    (%edx),%al
  8007d6:	74 ef                	je     8007c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d8:	0f b6 c0             	movzbl %al,%eax
  8007db:	0f b6 12             	movzbl (%edx),%edx
  8007de:	29 d0                	sub    %edx,%eax
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	53                   	push   %ebx
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ec:	89 c3                	mov    %eax,%ebx
  8007ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f1:	eb 06                	jmp    8007f9 <strncmp+0x17>
		n--, p++, q++;
  8007f3:	83 c0 01             	add    $0x1,%eax
  8007f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f9:	39 d8                	cmp    %ebx,%eax
  8007fb:	74 15                	je     800812 <strncmp+0x30>
  8007fd:	0f b6 08             	movzbl (%eax),%ecx
  800800:	84 c9                	test   %cl,%cl
  800802:	74 04                	je     800808 <strncmp+0x26>
  800804:	3a 0a                	cmp    (%edx),%cl
  800806:	74 eb                	je     8007f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800808:	0f b6 00             	movzbl (%eax),%eax
  80080b:	0f b6 12             	movzbl (%edx),%edx
  80080e:	29 d0                	sub    %edx,%eax
  800810:	eb 05                	jmp    800817 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800824:	eb 07                	jmp    80082d <strchr+0x13>
		if (*s == c)
  800826:	38 ca                	cmp    %cl,%dl
  800828:	74 0f                	je     800839 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082a:	83 c0 01             	add    $0x1,%eax
  80082d:	0f b6 10             	movzbl (%eax),%edx
  800830:	84 d2                	test   %dl,%dl
  800832:	75 f2                	jne    800826 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800845:	eb 03                	jmp    80084a <strfind+0xf>
  800847:	83 c0 01             	add    $0x1,%eax
  80084a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80084d:	38 ca                	cmp    %cl,%dl
  80084f:	74 04                	je     800855 <strfind+0x1a>
  800851:	84 d2                	test   %dl,%dl
  800853:	75 f2                	jne    800847 <strfind+0xc>
			break;
	return (char *) s;
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	57                   	push   %edi
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800860:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800863:	85 c9                	test   %ecx,%ecx
  800865:	74 36                	je     80089d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800867:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086d:	75 28                	jne    800897 <memset+0x40>
  80086f:	f6 c1 03             	test   $0x3,%cl
  800872:	75 23                	jne    800897 <memset+0x40>
		c &= 0xFF;
  800874:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800878:	89 d3                	mov    %edx,%ebx
  80087a:	c1 e3 08             	shl    $0x8,%ebx
  80087d:	89 d6                	mov    %edx,%esi
  80087f:	c1 e6 18             	shl    $0x18,%esi
  800882:	89 d0                	mov    %edx,%eax
  800884:	c1 e0 10             	shl    $0x10,%eax
  800887:	09 f0                	or     %esi,%eax
  800889:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80088b:	89 d8                	mov    %ebx,%eax
  80088d:	09 d0                	or     %edx,%eax
  80088f:	c1 e9 02             	shr    $0x2,%ecx
  800892:	fc                   	cld    
  800893:	f3 ab                	rep stos %eax,%es:(%edi)
  800895:	eb 06                	jmp    80089d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800897:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089a:	fc                   	cld    
  80089b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089d:	89 f8                	mov    %edi,%eax
  80089f:	5b                   	pop    %ebx
  8008a0:	5e                   	pop    %esi
  8008a1:	5f                   	pop    %edi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	57                   	push   %edi
  8008a8:	56                   	push   %esi
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b2:	39 c6                	cmp    %eax,%esi
  8008b4:	73 35                	jae    8008eb <memmove+0x47>
  8008b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b9:	39 d0                	cmp    %edx,%eax
  8008bb:	73 2e                	jae    8008eb <memmove+0x47>
		s += n;
		d += n;
  8008bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c0:	89 d6                	mov    %edx,%esi
  8008c2:	09 fe                	or     %edi,%esi
  8008c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ca:	75 13                	jne    8008df <memmove+0x3b>
  8008cc:	f6 c1 03             	test   $0x3,%cl
  8008cf:	75 0e                	jne    8008df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d1:	83 ef 04             	sub    $0x4,%edi
  8008d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
  8008da:	fd                   	std    
  8008db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008dd:	eb 09                	jmp    8008e8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008df:	83 ef 01             	sub    $0x1,%edi
  8008e2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e5:	fd                   	std    
  8008e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e8:	fc                   	cld    
  8008e9:	eb 1d                	jmp    800908 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008eb:	89 f2                	mov    %esi,%edx
  8008ed:	09 c2                	or     %eax,%edx
  8008ef:	f6 c2 03             	test   $0x3,%dl
  8008f2:	75 0f                	jne    800903 <memmove+0x5f>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 0a                	jne    800903 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f9:	c1 e9 02             	shr    $0x2,%ecx
  8008fc:	89 c7                	mov    %eax,%edi
  8008fe:	fc                   	cld    
  8008ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800901:	eb 05                	jmp    800908 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800903:	89 c7                	mov    %eax,%edi
  800905:	fc                   	cld    
  800906:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090f:	ff 75 10             	pushl  0x10(%ebp)
  800912:	ff 75 0c             	pushl  0xc(%ebp)
  800915:	ff 75 08             	pushl  0x8(%ebp)
  800918:	e8 87 ff ff ff       	call   8008a4 <memmove>
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092a:	89 c6                	mov    %eax,%esi
  80092c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092f:	eb 1a                	jmp    80094b <memcmp+0x2c>
		if (*s1 != *s2)
  800931:	0f b6 08             	movzbl (%eax),%ecx
  800934:	0f b6 1a             	movzbl (%edx),%ebx
  800937:	38 d9                	cmp    %bl,%cl
  800939:	74 0a                	je     800945 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093b:	0f b6 c1             	movzbl %cl,%eax
  80093e:	0f b6 db             	movzbl %bl,%ebx
  800941:	29 d8                	sub    %ebx,%eax
  800943:	eb 0f                	jmp    800954 <memcmp+0x35>
		s1++, s2++;
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094b:	39 f0                	cmp    %esi,%eax
  80094d:	75 e2                	jne    800931 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	53                   	push   %ebx
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80095f:	89 c1                	mov    %eax,%ecx
  800961:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800964:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800968:	eb 0a                	jmp    800974 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096a:	0f b6 10             	movzbl (%eax),%edx
  80096d:	39 da                	cmp    %ebx,%edx
  80096f:	74 07                	je     800978 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	39 c8                	cmp    %ecx,%eax
  800976:	72 f2                	jb     80096a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800984:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800987:	eb 03                	jmp    80098c <strtol+0x11>
		s++;
  800989:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098c:	0f b6 01             	movzbl (%ecx),%eax
  80098f:	3c 20                	cmp    $0x20,%al
  800991:	74 f6                	je     800989 <strtol+0xe>
  800993:	3c 09                	cmp    $0x9,%al
  800995:	74 f2                	je     800989 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800997:	3c 2b                	cmp    $0x2b,%al
  800999:	75 0a                	jne    8009a5 <strtol+0x2a>
		s++;
  80099b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099e:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a3:	eb 11                	jmp    8009b6 <strtol+0x3b>
  8009a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009aa:	3c 2d                	cmp    $0x2d,%al
  8009ac:	75 08                	jne    8009b6 <strtol+0x3b>
		s++, neg = 1;
  8009ae:	83 c1 01             	add    $0x1,%ecx
  8009b1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009bc:	75 15                	jne    8009d3 <strtol+0x58>
  8009be:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c1:	75 10                	jne    8009d3 <strtol+0x58>
  8009c3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c7:	75 7c                	jne    800a45 <strtol+0xca>
		s += 2, base = 16;
  8009c9:	83 c1 02             	add    $0x2,%ecx
  8009cc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d1:	eb 16                	jmp    8009e9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d3:	85 db                	test   %ebx,%ebx
  8009d5:	75 12                	jne    8009e9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009dc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009df:	75 08                	jne    8009e9 <strtol+0x6e>
		s++, base = 8;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ee:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f1:	0f b6 11             	movzbl (%ecx),%edx
  8009f4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f7:	89 f3                	mov    %esi,%ebx
  8009f9:	80 fb 09             	cmp    $0x9,%bl
  8009fc:	77 08                	ja     800a06 <strtol+0x8b>
			dig = *s - '0';
  8009fe:	0f be d2             	movsbl %dl,%edx
  800a01:	83 ea 30             	sub    $0x30,%edx
  800a04:	eb 22                	jmp    800a28 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a06:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a09:	89 f3                	mov    %esi,%ebx
  800a0b:	80 fb 19             	cmp    $0x19,%bl
  800a0e:	77 08                	ja     800a18 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a10:	0f be d2             	movsbl %dl,%edx
  800a13:	83 ea 57             	sub    $0x57,%edx
  800a16:	eb 10                	jmp    800a28 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a18:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1b:	89 f3                	mov    %esi,%ebx
  800a1d:	80 fb 19             	cmp    $0x19,%bl
  800a20:	77 16                	ja     800a38 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a22:	0f be d2             	movsbl %dl,%edx
  800a25:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a28:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2b:	7d 0b                	jge    800a38 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a2d:	83 c1 01             	add    $0x1,%ecx
  800a30:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a34:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a36:	eb b9                	jmp    8009f1 <strtol+0x76>

	if (endptr)
  800a38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3c:	74 0d                	je     800a4b <strtol+0xd0>
		*endptr = (char *) s;
  800a3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a41:	89 0e                	mov    %ecx,(%esi)
  800a43:	eb 06                	jmp    800a4b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a45:	85 db                	test   %ebx,%ebx
  800a47:	74 98                	je     8009e1 <strtol+0x66>
  800a49:	eb 9e                	jmp    8009e9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	f7 da                	neg    %edx
  800a4f:	85 ff                	test   %edi,%edi
  800a51:	0f 45 c2             	cmovne %edx,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6a:	89 c3                	mov    %eax,%ebx
  800a6c:	89 c7                	mov    %eax,%edi
  800a6e:	89 c6                	mov    %eax,%esi
  800a70:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	b8 01 00 00 00       	mov    $0x1,%eax
  800a87:	89 d1                	mov    %edx,%ecx
  800a89:	89 d3                	mov    %edx,%ebx
  800a8b:	89 d7                	mov    %edx,%edi
  800a8d:	89 d6                	mov    %edx,%esi
  800a8f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa4:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	89 cb                	mov    %ecx,%ebx
  800aae:	89 cf                	mov    %ecx,%edi
  800ab0:	89 ce                	mov    %ecx,%esi
  800ab2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	7e 17                	jle    800acf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab8:	83 ec 0c             	sub    $0xc,%esp
  800abb:	50                   	push   %eax
  800abc:	6a 03                	push   $0x3
  800abe:	68 5f 21 80 00       	push   $0x80215f
  800ac3:	6a 23                	push   $0x23
  800ac5:	68 7c 21 80 00       	push   $0x80217c
  800aca:	e8 f5 0e 00 00       	call   8019c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae7:	89 d1                	mov    %edx,%ecx
  800ae9:	89 d3                	mov    %edx,%ebx
  800aeb:	89 d7                	mov    %edx,%edi
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_yield>:

void
sys_yield(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	be 00 00 00 00       	mov    $0x0,%esi
  800b23:	b8 04 00 00 00       	mov    $0x4,%eax
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b31:	89 f7                	mov    %esi,%edi
  800b33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	7e 17                	jle    800b50 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	50                   	push   %eax
  800b3d:	6a 04                	push   $0x4
  800b3f:	68 5f 21 80 00       	push   $0x80215f
  800b44:	6a 23                	push   $0x23
  800b46:	68 7c 21 80 00       	push   $0x80217c
  800b4b:	e8 74 0e 00 00       	call   8019c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	b8 05 00 00 00       	mov    $0x5,%eax
  800b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b72:	8b 75 18             	mov    0x18(%ebp),%esi
  800b75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 17                	jle    800b92 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	50                   	push   %eax
  800b7f:	6a 05                	push   $0x5
  800b81:	68 5f 21 80 00       	push   $0x80215f
  800b86:	6a 23                	push   $0x23
  800b88:	68 7c 21 80 00       	push   $0x80217c
  800b8d:	e8 32 0e 00 00       	call   8019c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	89 df                	mov    %ebx,%edi
  800bb5:	89 de                	mov    %ebx,%esi
  800bb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 06                	push   $0x6
  800bc3:	68 5f 21 80 00       	push   $0x80215f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 7c 21 80 00       	push   $0x80217c
  800bcf:	e8 f0 0d 00 00       	call   8019c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 08 00 00 00       	mov    $0x8,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 08                	push   $0x8
  800c05:	68 5f 21 80 00       	push   $0x80215f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 7c 21 80 00       	push   $0x80217c
  800c11:	e8 ae 0d 00 00       	call   8019c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 df                	mov    %ebx,%edi
  800c39:	89 de                	mov    %ebx,%esi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 09                	push   $0x9
  800c47:	68 5f 21 80 00       	push   $0x80215f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 7c 21 80 00       	push   $0x80217c
  800c53:	e8 6c 0d 00 00       	call   8019c4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 0a                	push   $0xa
  800c89:	68 5f 21 80 00       	push   $0x80215f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 7c 21 80 00       	push   $0x80217c
  800c95:	e8 2a 0d 00 00       	call   8019c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	be 00 00 00 00       	mov    $0x0,%esi
  800cad:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 cb                	mov    %ecx,%ebx
  800cdd:	89 cf                	mov    %ecx,%edi
  800cdf:	89 ce                	mov    %ecx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 0d                	push   $0xd
  800ced:	68 5f 21 80 00       	push   $0x80215f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 7c 21 80 00       	push   $0x80217c
  800cf9:	e8 c6 0c 00 00       	call   8019c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d11:	c1 e8 0c             	shr    $0xc,%eax
}
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d26:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d33:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d38:	89 c2                	mov    %eax,%edx
  800d3a:	c1 ea 16             	shr    $0x16,%edx
  800d3d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d44:	f6 c2 01             	test   $0x1,%dl
  800d47:	74 11                	je     800d5a <fd_alloc+0x2d>
  800d49:	89 c2                	mov    %eax,%edx
  800d4b:	c1 ea 0c             	shr    $0xc,%edx
  800d4e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d55:	f6 c2 01             	test   $0x1,%dl
  800d58:	75 09                	jne    800d63 <fd_alloc+0x36>
			*fd_store = fd;
  800d5a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d61:	eb 17                	jmp    800d7a <fd_alloc+0x4d>
  800d63:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d68:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d6d:	75 c9                	jne    800d38 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d6f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d75:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d82:	83 f8 1f             	cmp    $0x1f,%eax
  800d85:	77 36                	ja     800dbd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d87:	c1 e0 0c             	shl    $0xc,%eax
  800d8a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d8f:	89 c2                	mov    %eax,%edx
  800d91:	c1 ea 16             	shr    $0x16,%edx
  800d94:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d9b:	f6 c2 01             	test   $0x1,%dl
  800d9e:	74 24                	je     800dc4 <fd_lookup+0x48>
  800da0:	89 c2                	mov    %eax,%edx
  800da2:	c1 ea 0c             	shr    $0xc,%edx
  800da5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dac:	f6 c2 01             	test   $0x1,%dl
  800daf:	74 1a                	je     800dcb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800db1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db4:	89 02                	mov    %eax,(%edx)
	return 0;
  800db6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbb:	eb 13                	jmp    800dd0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc2:	eb 0c                	jmp    800dd0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc9:	eb 05                	jmp    800dd0 <fd_lookup+0x54>
  800dcb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	83 ec 08             	sub    $0x8,%esp
  800dd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddb:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800de0:	eb 13                	jmp    800df5 <dev_lookup+0x23>
  800de2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800de5:	39 08                	cmp    %ecx,(%eax)
  800de7:	75 0c                	jne    800df5 <dev_lookup+0x23>
			*dev = devtab[i];
  800de9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dec:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dee:	b8 00 00 00 00       	mov    $0x0,%eax
  800df3:	eb 2e                	jmp    800e23 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800df5:	8b 02                	mov    (%edx),%eax
  800df7:	85 c0                	test   %eax,%eax
  800df9:	75 e7                	jne    800de2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dfb:	a1 04 40 80 00       	mov    0x804004,%eax
  800e00:	8b 40 48             	mov    0x48(%eax),%eax
  800e03:	83 ec 04             	sub    $0x4,%esp
  800e06:	51                   	push   %ecx
  800e07:	50                   	push   %eax
  800e08:	68 8c 21 80 00       	push   $0x80218c
  800e0d:	e8 7b f3 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800e12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e15:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e1b:	83 c4 10             	add    $0x10,%esp
  800e1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    

00800e25 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
  800e2a:	83 ec 10             	sub    $0x10,%esp
  800e2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e36:	50                   	push   %eax
  800e37:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e3d:	c1 e8 0c             	shr    $0xc,%eax
  800e40:	50                   	push   %eax
  800e41:	e8 36 ff ff ff       	call   800d7c <fd_lookup>
  800e46:	83 c4 08             	add    $0x8,%esp
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	78 05                	js     800e52 <fd_close+0x2d>
	    || fd != fd2)
  800e4d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e50:	74 0c                	je     800e5e <fd_close+0x39>
		return (must_exist ? r : 0);
  800e52:	84 db                	test   %bl,%bl
  800e54:	ba 00 00 00 00       	mov    $0x0,%edx
  800e59:	0f 44 c2             	cmove  %edx,%eax
  800e5c:	eb 41                	jmp    800e9f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e5e:	83 ec 08             	sub    $0x8,%esp
  800e61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e64:	50                   	push   %eax
  800e65:	ff 36                	pushl  (%esi)
  800e67:	e8 66 ff ff ff       	call   800dd2 <dev_lookup>
  800e6c:	89 c3                	mov    %eax,%ebx
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	85 c0                	test   %eax,%eax
  800e73:	78 1a                	js     800e8f <fd_close+0x6a>
		if (dev->dev_close)
  800e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e78:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e7b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	74 0b                	je     800e8f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	56                   	push   %esi
  800e88:	ff d0                	call   *%eax
  800e8a:	89 c3                	mov    %eax,%ebx
  800e8c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e8f:	83 ec 08             	sub    $0x8,%esp
  800e92:	56                   	push   %esi
  800e93:	6a 00                	push   $0x0
  800e95:	e8 00 fd ff ff       	call   800b9a <sys_page_unmap>
	return r;
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	89 d8                	mov    %ebx,%eax
}
  800e9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eaf:	50                   	push   %eax
  800eb0:	ff 75 08             	pushl  0x8(%ebp)
  800eb3:	e8 c4 fe ff ff       	call   800d7c <fd_lookup>
  800eb8:	83 c4 08             	add    $0x8,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 10                	js     800ecf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ebf:	83 ec 08             	sub    $0x8,%esp
  800ec2:	6a 01                	push   $0x1
  800ec4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec7:	e8 59 ff ff ff       	call   800e25 <fd_close>
  800ecc:	83 c4 10             	add    $0x10,%esp
}
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <close_all>:

void
close_all(void)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	53                   	push   %ebx
  800ed5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ed8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	53                   	push   %ebx
  800ee1:	e8 c0 ff ff ff       	call   800ea6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee6:	83 c3 01             	add    $0x1,%ebx
  800ee9:	83 c4 10             	add    $0x10,%esp
  800eec:	83 fb 20             	cmp    $0x20,%ebx
  800eef:	75 ec                	jne    800edd <close_all+0xc>
		close(i);
}
  800ef1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	57                   	push   %edi
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	83 ec 2c             	sub    $0x2c,%esp
  800eff:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f02:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f05:	50                   	push   %eax
  800f06:	ff 75 08             	pushl  0x8(%ebp)
  800f09:	e8 6e fe ff ff       	call   800d7c <fd_lookup>
  800f0e:	83 c4 08             	add    $0x8,%esp
  800f11:	85 c0                	test   %eax,%eax
  800f13:	0f 88 c1 00 00 00    	js     800fda <dup+0xe4>
		return r;
	close(newfdnum);
  800f19:	83 ec 0c             	sub    $0xc,%esp
  800f1c:	56                   	push   %esi
  800f1d:	e8 84 ff ff ff       	call   800ea6 <close>

	newfd = INDEX2FD(newfdnum);
  800f22:	89 f3                	mov    %esi,%ebx
  800f24:	c1 e3 0c             	shl    $0xc,%ebx
  800f27:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f2d:	83 c4 04             	add    $0x4,%esp
  800f30:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f33:	e8 de fd ff ff       	call   800d16 <fd2data>
  800f38:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f3a:	89 1c 24             	mov    %ebx,(%esp)
  800f3d:	e8 d4 fd ff ff       	call   800d16 <fd2data>
  800f42:	83 c4 10             	add    $0x10,%esp
  800f45:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f48:	89 f8                	mov    %edi,%eax
  800f4a:	c1 e8 16             	shr    $0x16,%eax
  800f4d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f54:	a8 01                	test   $0x1,%al
  800f56:	74 37                	je     800f8f <dup+0x99>
  800f58:	89 f8                	mov    %edi,%eax
  800f5a:	c1 e8 0c             	shr    $0xc,%eax
  800f5d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f64:	f6 c2 01             	test   $0x1,%dl
  800f67:	74 26                	je     800f8f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f69:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	25 07 0e 00 00       	and    $0xe07,%eax
  800f78:	50                   	push   %eax
  800f79:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f7c:	6a 00                	push   $0x0
  800f7e:	57                   	push   %edi
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 d2 fb ff ff       	call   800b58 <sys_page_map>
  800f86:	89 c7                	mov    %eax,%edi
  800f88:	83 c4 20             	add    $0x20,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	78 2e                	js     800fbd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f8f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f92:	89 d0                	mov    %edx,%eax
  800f94:	c1 e8 0c             	shr    $0xc,%eax
  800f97:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9e:	83 ec 0c             	sub    $0xc,%esp
  800fa1:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa6:	50                   	push   %eax
  800fa7:	53                   	push   %ebx
  800fa8:	6a 00                	push   $0x0
  800faa:	52                   	push   %edx
  800fab:	6a 00                	push   $0x0
  800fad:	e8 a6 fb ff ff       	call   800b58 <sys_page_map>
  800fb2:	89 c7                	mov    %eax,%edi
  800fb4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fb7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb9:	85 ff                	test   %edi,%edi
  800fbb:	79 1d                	jns    800fda <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	53                   	push   %ebx
  800fc1:	6a 00                	push   $0x0
  800fc3:	e8 d2 fb ff ff       	call   800b9a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fc8:	83 c4 08             	add    $0x8,%esp
  800fcb:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fce:	6a 00                	push   $0x0
  800fd0:	e8 c5 fb ff ff       	call   800b9a <sys_page_unmap>
	return r;
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	89 f8                	mov    %edi,%eax
}
  800fda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5f                   	pop    %edi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	53                   	push   %ebx
  800fe6:	83 ec 14             	sub    $0x14,%esp
  800fe9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fef:	50                   	push   %eax
  800ff0:	53                   	push   %ebx
  800ff1:	e8 86 fd ff ff       	call   800d7c <fd_lookup>
  800ff6:	83 c4 08             	add    $0x8,%esp
  800ff9:	89 c2                	mov    %eax,%edx
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	78 6d                	js     80106c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fff:	83 ec 08             	sub    $0x8,%esp
  801002:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801005:	50                   	push   %eax
  801006:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801009:	ff 30                	pushl  (%eax)
  80100b:	e8 c2 fd ff ff       	call   800dd2 <dev_lookup>
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	85 c0                	test   %eax,%eax
  801015:	78 4c                	js     801063 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801017:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80101a:	8b 42 08             	mov    0x8(%edx),%eax
  80101d:	83 e0 03             	and    $0x3,%eax
  801020:	83 f8 01             	cmp    $0x1,%eax
  801023:	75 21                	jne    801046 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801025:	a1 04 40 80 00       	mov    0x804004,%eax
  80102a:	8b 40 48             	mov    0x48(%eax),%eax
  80102d:	83 ec 04             	sub    $0x4,%esp
  801030:	53                   	push   %ebx
  801031:	50                   	push   %eax
  801032:	68 cd 21 80 00       	push   $0x8021cd
  801037:	e8 51 f1 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801044:	eb 26                	jmp    80106c <read+0x8a>
	}
	if (!dev->dev_read)
  801046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801049:	8b 40 08             	mov    0x8(%eax),%eax
  80104c:	85 c0                	test   %eax,%eax
  80104e:	74 17                	je     801067 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801050:	83 ec 04             	sub    $0x4,%esp
  801053:	ff 75 10             	pushl  0x10(%ebp)
  801056:	ff 75 0c             	pushl  0xc(%ebp)
  801059:	52                   	push   %edx
  80105a:	ff d0                	call   *%eax
  80105c:	89 c2                	mov    %eax,%edx
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	eb 09                	jmp    80106c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801063:	89 c2                	mov    %eax,%edx
  801065:	eb 05                	jmp    80106c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801067:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80106c:	89 d0                	mov    %edx,%eax
  80106e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80107f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801082:	bb 00 00 00 00       	mov    $0x0,%ebx
  801087:	eb 21                	jmp    8010aa <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801089:	83 ec 04             	sub    $0x4,%esp
  80108c:	89 f0                	mov    %esi,%eax
  80108e:	29 d8                	sub    %ebx,%eax
  801090:	50                   	push   %eax
  801091:	89 d8                	mov    %ebx,%eax
  801093:	03 45 0c             	add    0xc(%ebp),%eax
  801096:	50                   	push   %eax
  801097:	57                   	push   %edi
  801098:	e8 45 ff ff ff       	call   800fe2 <read>
		if (m < 0)
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 10                	js     8010b4 <readn+0x41>
			return m;
		if (m == 0)
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	74 0a                	je     8010b2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a8:	01 c3                	add    %eax,%ebx
  8010aa:	39 f3                	cmp    %esi,%ebx
  8010ac:	72 db                	jb     801089 <readn+0x16>
  8010ae:	89 d8                	mov    %ebx,%eax
  8010b0:	eb 02                	jmp    8010b4 <readn+0x41>
  8010b2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5f                   	pop    %edi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 14             	sub    $0x14,%esp
  8010c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	53                   	push   %ebx
  8010cb:	e8 ac fc ff ff       	call   800d7c <fd_lookup>
  8010d0:	83 c4 08             	add    $0x8,%esp
  8010d3:	89 c2                	mov    %eax,%edx
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	78 68                	js     801141 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d9:	83 ec 08             	sub    $0x8,%esp
  8010dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010df:	50                   	push   %eax
  8010e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e3:	ff 30                	pushl  (%eax)
  8010e5:	e8 e8 fc ff ff       	call   800dd2 <dev_lookup>
  8010ea:	83 c4 10             	add    $0x10,%esp
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	78 47                	js     801138 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010f8:	75 21                	jne    80111b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ff:	8b 40 48             	mov    0x48(%eax),%eax
  801102:	83 ec 04             	sub    $0x4,%esp
  801105:	53                   	push   %ebx
  801106:	50                   	push   %eax
  801107:	68 e9 21 80 00       	push   $0x8021e9
  80110c:	e8 7c f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801119:	eb 26                	jmp    801141 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80111b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80111e:	8b 52 0c             	mov    0xc(%edx),%edx
  801121:	85 d2                	test   %edx,%edx
  801123:	74 17                	je     80113c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801125:	83 ec 04             	sub    $0x4,%esp
  801128:	ff 75 10             	pushl  0x10(%ebp)
  80112b:	ff 75 0c             	pushl  0xc(%ebp)
  80112e:	50                   	push   %eax
  80112f:	ff d2                	call   *%edx
  801131:	89 c2                	mov    %eax,%edx
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	eb 09                	jmp    801141 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801138:	89 c2                	mov    %eax,%edx
  80113a:	eb 05                	jmp    801141 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80113c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801141:	89 d0                	mov    %edx,%eax
  801143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801146:	c9                   	leave  
  801147:	c3                   	ret    

00801148 <seek>:

int
seek(int fdnum, off_t offset)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80114e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	ff 75 08             	pushl  0x8(%ebp)
  801155:	e8 22 fc ff ff       	call   800d7c <fd_lookup>
  80115a:	83 c4 08             	add    $0x8,%esp
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 0e                	js     80116f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801161:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801164:	8b 55 0c             	mov    0xc(%ebp),%edx
  801167:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80116a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	53                   	push   %ebx
  801175:	83 ec 14             	sub    $0x14,%esp
  801178:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	53                   	push   %ebx
  801180:	e8 f7 fb ff ff       	call   800d7c <fd_lookup>
  801185:	83 c4 08             	add    $0x8,%esp
  801188:	89 c2                	mov    %eax,%edx
  80118a:	85 c0                	test   %eax,%eax
  80118c:	78 65                	js     8011f3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118e:	83 ec 08             	sub    $0x8,%esp
  801191:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801194:	50                   	push   %eax
  801195:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801198:	ff 30                	pushl  (%eax)
  80119a:	e8 33 fc ff ff       	call   800dd2 <dev_lookup>
  80119f:	83 c4 10             	add    $0x10,%esp
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	78 44                	js     8011ea <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ad:	75 21                	jne    8011d0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011af:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011b4:	8b 40 48             	mov    0x48(%eax),%eax
  8011b7:	83 ec 04             	sub    $0x4,%esp
  8011ba:	53                   	push   %ebx
  8011bb:	50                   	push   %eax
  8011bc:	68 ac 21 80 00       	push   $0x8021ac
  8011c1:	e8 c7 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ce:	eb 23                	jmp    8011f3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d3:	8b 52 18             	mov    0x18(%edx),%edx
  8011d6:	85 d2                	test   %edx,%edx
  8011d8:	74 14                	je     8011ee <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	ff 75 0c             	pushl  0xc(%ebp)
  8011e0:	50                   	push   %eax
  8011e1:	ff d2                	call   *%edx
  8011e3:	89 c2                	mov    %eax,%edx
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	eb 09                	jmp    8011f3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	eb 05                	jmp    8011f3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011f3:	89 d0                	mov    %edx,%eax
  8011f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 14             	sub    $0x14,%esp
  801201:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801204:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801207:	50                   	push   %eax
  801208:	ff 75 08             	pushl  0x8(%ebp)
  80120b:	e8 6c fb ff ff       	call   800d7c <fd_lookup>
  801210:	83 c4 08             	add    $0x8,%esp
  801213:	89 c2                	mov    %eax,%edx
  801215:	85 c0                	test   %eax,%eax
  801217:	78 58                	js     801271 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801219:	83 ec 08             	sub    $0x8,%esp
  80121c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801223:	ff 30                	pushl  (%eax)
  801225:	e8 a8 fb ff ff       	call   800dd2 <dev_lookup>
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 37                	js     801268 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801231:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801234:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801238:	74 32                	je     80126c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80123a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80123d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801244:	00 00 00 
	stat->st_isdir = 0;
  801247:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80124e:	00 00 00 
	stat->st_dev = dev;
  801251:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	53                   	push   %ebx
  80125b:	ff 75 f0             	pushl  -0x10(%ebp)
  80125e:	ff 50 14             	call   *0x14(%eax)
  801261:	89 c2                	mov    %eax,%edx
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	eb 09                	jmp    801271 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801268:	89 c2                	mov    %eax,%edx
  80126a:	eb 05                	jmp    801271 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80126c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801271:	89 d0                	mov    %edx,%eax
  801273:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801276:	c9                   	leave  
  801277:	c3                   	ret    

00801278 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	56                   	push   %esi
  80127c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	6a 00                	push   $0x0
  801282:	ff 75 08             	pushl  0x8(%ebp)
  801285:	e8 b7 01 00 00       	call   801441 <open>
  80128a:	89 c3                	mov    %eax,%ebx
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 1b                	js     8012ae <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801293:	83 ec 08             	sub    $0x8,%esp
  801296:	ff 75 0c             	pushl  0xc(%ebp)
  801299:	50                   	push   %eax
  80129a:	e8 5b ff ff ff       	call   8011fa <fstat>
  80129f:	89 c6                	mov    %eax,%esi
	close(fd);
  8012a1:	89 1c 24             	mov    %ebx,(%esp)
  8012a4:	e8 fd fb ff ff       	call   800ea6 <close>
	return r;
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	89 f0                	mov    %esi,%eax
}
  8012ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b1:	5b                   	pop    %ebx
  8012b2:	5e                   	pop    %esi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	56                   	push   %esi
  8012b9:	53                   	push   %ebx
  8012ba:	89 c6                	mov    %eax,%esi
  8012bc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012be:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012c5:	75 12                	jne    8012d9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	6a 01                	push   $0x1
  8012cc:	e8 f4 07 00 00       	call   801ac5 <ipc_find_env>
  8012d1:	a3 00 40 80 00       	mov    %eax,0x804000
  8012d6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012d9:	6a 07                	push   $0x7
  8012db:	68 00 50 80 00       	push   $0x805000
  8012e0:	56                   	push   %esi
  8012e1:	ff 35 00 40 80 00    	pushl  0x804000
  8012e7:	e8 85 07 00 00       	call   801a71 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012ec:	83 c4 0c             	add    $0xc,%esp
  8012ef:	6a 00                	push   $0x0
  8012f1:	53                   	push   %ebx
  8012f2:	6a 00                	push   $0x0
  8012f4:	e8 11 07 00 00       	call   801a0a <ipc_recv>
}
  8012f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fc:	5b                   	pop    %ebx
  8012fd:	5e                   	pop    %esi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801306:	8b 45 08             	mov    0x8(%ebp),%eax
  801309:	8b 40 0c             	mov    0xc(%eax),%eax
  80130c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801311:	8b 45 0c             	mov    0xc(%ebp),%eax
  801314:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801319:	ba 00 00 00 00       	mov    $0x0,%edx
  80131e:	b8 02 00 00 00       	mov    $0x2,%eax
  801323:	e8 8d ff ff ff       	call   8012b5 <fsipc>
}
  801328:	c9                   	leave  
  801329:	c3                   	ret    

0080132a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	8b 40 0c             	mov    0xc(%eax),%eax
  801336:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80133b:	ba 00 00 00 00       	mov    $0x0,%edx
  801340:	b8 06 00 00 00       	mov    $0x6,%eax
  801345:	e8 6b ff ff ff       	call   8012b5 <fsipc>
}
  80134a:	c9                   	leave  
  80134b:	c3                   	ret    

0080134c <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	53                   	push   %ebx
  801350:	83 ec 04             	sub    $0x4,%esp
  801353:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801356:	8b 45 08             	mov    0x8(%ebp),%eax
  801359:	8b 40 0c             	mov    0xc(%eax),%eax
  80135c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801361:	ba 00 00 00 00       	mov    $0x0,%edx
  801366:	b8 05 00 00 00       	mov    $0x5,%eax
  80136b:	e8 45 ff ff ff       	call   8012b5 <fsipc>
  801370:	85 c0                	test   %eax,%eax
  801372:	78 2c                	js     8013a0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	68 00 50 80 00       	push   $0x805000
  80137c:	53                   	push   %ebx
  80137d:	e8 90 f3 ff ff       	call   800712 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801382:	a1 80 50 80 00       	mov    0x805080,%eax
  801387:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80138d:	a1 84 50 80 00       	mov    0x805084,%eax
  801392:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8013ab:	68 18 22 80 00       	push   $0x802218
  8013b0:	68 90 00 00 00       	push   $0x90
  8013b5:	68 36 22 80 00       	push   $0x802236
  8013ba:	e8 05 06 00 00       	call   8019c4 <_panic>

008013bf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	56                   	push   %esi
  8013c3:	53                   	push   %ebx
  8013c4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013d2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8013e2:	e8 ce fe ff ff       	call   8012b5 <fsipc>
  8013e7:	89 c3                	mov    %eax,%ebx
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 4b                	js     801438 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013ed:	39 c6                	cmp    %eax,%esi
  8013ef:	73 16                	jae    801407 <devfile_read+0x48>
  8013f1:	68 41 22 80 00       	push   $0x802241
  8013f6:	68 48 22 80 00       	push   $0x802248
  8013fb:	6a 7c                	push   $0x7c
  8013fd:	68 36 22 80 00       	push   $0x802236
  801402:	e8 bd 05 00 00       	call   8019c4 <_panic>
	assert(r <= PGSIZE);
  801407:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80140c:	7e 16                	jle    801424 <devfile_read+0x65>
  80140e:	68 5d 22 80 00       	push   $0x80225d
  801413:	68 48 22 80 00       	push   $0x802248
  801418:	6a 7d                	push   $0x7d
  80141a:	68 36 22 80 00       	push   $0x802236
  80141f:	e8 a0 05 00 00       	call   8019c4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801424:	83 ec 04             	sub    $0x4,%esp
  801427:	50                   	push   %eax
  801428:	68 00 50 80 00       	push   $0x805000
  80142d:	ff 75 0c             	pushl  0xc(%ebp)
  801430:	e8 6f f4 ff ff       	call   8008a4 <memmove>
	return r;
  801435:	83 c4 10             	add    $0x10,%esp
}
  801438:	89 d8                	mov    %ebx,%eax
  80143a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143d:	5b                   	pop    %ebx
  80143e:	5e                   	pop    %esi
  80143f:	5d                   	pop    %ebp
  801440:	c3                   	ret    

00801441 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	53                   	push   %ebx
  801445:	83 ec 20             	sub    $0x20,%esp
  801448:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80144b:	53                   	push   %ebx
  80144c:	e8 88 f2 ff ff       	call   8006d9 <strlen>
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801459:	7f 67                	jg     8014c2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80145b:	83 ec 0c             	sub    $0xc,%esp
  80145e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	e8 c6 f8 ff ff       	call   800d2d <fd_alloc>
  801467:	83 c4 10             	add    $0x10,%esp
		return r;
  80146a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 57                	js     8014c7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	53                   	push   %ebx
  801474:	68 00 50 80 00       	push   $0x805000
  801479:	e8 94 f2 ff ff       	call   800712 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80147e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801481:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801486:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801489:	b8 01 00 00 00       	mov    $0x1,%eax
  80148e:	e8 22 fe ff ff       	call   8012b5 <fsipc>
  801493:	89 c3                	mov    %eax,%ebx
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	79 14                	jns    8014b0 <open+0x6f>
		fd_close(fd, 0);
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	6a 00                	push   $0x0
  8014a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a4:	e8 7c f9 ff ff       	call   800e25 <fd_close>
		return r;
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	89 da                	mov    %ebx,%edx
  8014ae:	eb 17                	jmp    8014c7 <open+0x86>
	}

	return fd2num(fd);
  8014b0:	83 ec 0c             	sub    $0xc,%esp
  8014b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b6:	e8 4b f8 ff ff       	call   800d06 <fd2num>
  8014bb:	89 c2                	mov    %eax,%edx
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	eb 05                	jmp    8014c7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014c2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014c7:	89 d0                	mov    %edx,%eax
  8014c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d9:	b8 08 00 00 00       	mov    $0x8,%eax
  8014de:	e8 d2 fd ff ff       	call   8012b5 <fsipc>
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	56                   	push   %esi
  8014e9:	53                   	push   %ebx
  8014ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014ed:	83 ec 0c             	sub    $0xc,%esp
  8014f0:	ff 75 08             	pushl  0x8(%ebp)
  8014f3:	e8 1e f8 ff ff       	call   800d16 <fd2data>
  8014f8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8014fa:	83 c4 08             	add    $0x8,%esp
  8014fd:	68 69 22 80 00       	push   $0x802269
  801502:	53                   	push   %ebx
  801503:	e8 0a f2 ff ff       	call   800712 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801508:	8b 46 04             	mov    0x4(%esi),%eax
  80150b:	2b 06                	sub    (%esi),%eax
  80150d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801513:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80151a:	00 00 00 
	stat->st_dev = &devpipe;
  80151d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801524:	30 80 00 
	return 0;
}
  801527:	b8 00 00 00 00       	mov    $0x0,%eax
  80152c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152f:	5b                   	pop    %ebx
  801530:	5e                   	pop    %esi
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    

00801533 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80153d:	53                   	push   %ebx
  80153e:	6a 00                	push   $0x0
  801540:	e8 55 f6 ff ff       	call   800b9a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801545:	89 1c 24             	mov    %ebx,(%esp)
  801548:	e8 c9 f7 ff ff       	call   800d16 <fd2data>
  80154d:	83 c4 08             	add    $0x8,%esp
  801550:	50                   	push   %eax
  801551:	6a 00                	push   $0x0
  801553:	e8 42 f6 ff ff       	call   800b9a <sys_page_unmap>
}
  801558:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	57                   	push   %edi
  801561:	56                   	push   %esi
  801562:	53                   	push   %ebx
  801563:	83 ec 1c             	sub    $0x1c,%esp
  801566:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801569:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80156b:	a1 04 40 80 00       	mov    0x804004,%eax
  801570:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801573:	83 ec 0c             	sub    $0xc,%esp
  801576:	ff 75 e0             	pushl  -0x20(%ebp)
  801579:	e8 80 05 00 00       	call   801afe <pageref>
  80157e:	89 c3                	mov    %eax,%ebx
  801580:	89 3c 24             	mov    %edi,(%esp)
  801583:	e8 76 05 00 00       	call   801afe <pageref>
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	39 c3                	cmp    %eax,%ebx
  80158d:	0f 94 c1             	sete   %cl
  801590:	0f b6 c9             	movzbl %cl,%ecx
  801593:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801596:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80159c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80159f:	39 ce                	cmp    %ecx,%esi
  8015a1:	74 1b                	je     8015be <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015a3:	39 c3                	cmp    %eax,%ebx
  8015a5:	75 c4                	jne    80156b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015a7:	8b 42 58             	mov    0x58(%edx),%eax
  8015aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ad:	50                   	push   %eax
  8015ae:	56                   	push   %esi
  8015af:	68 70 22 80 00       	push   $0x802270
  8015b4:	e8 d4 eb ff ff       	call   80018d <cprintf>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	eb ad                	jmp    80156b <_pipeisclosed+0xe>
	}
}
  8015be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	57                   	push   %edi
  8015cd:	56                   	push   %esi
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 28             	sub    $0x28,%esp
  8015d2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015d5:	56                   	push   %esi
  8015d6:	e8 3b f7 ff ff       	call   800d16 <fd2data>
  8015db:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8015e5:	eb 4b                	jmp    801632 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015e7:	89 da                	mov    %ebx,%edx
  8015e9:	89 f0                	mov    %esi,%eax
  8015eb:	e8 6d ff ff ff       	call   80155d <_pipeisclosed>
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	75 48                	jne    80163c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015f4:	e8 fd f4 ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015f9:	8b 43 04             	mov    0x4(%ebx),%eax
  8015fc:	8b 0b                	mov    (%ebx),%ecx
  8015fe:	8d 51 20             	lea    0x20(%ecx),%edx
  801601:	39 d0                	cmp    %edx,%eax
  801603:	73 e2                	jae    8015e7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801605:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801608:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80160c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80160f:	89 c2                	mov    %eax,%edx
  801611:	c1 fa 1f             	sar    $0x1f,%edx
  801614:	89 d1                	mov    %edx,%ecx
  801616:	c1 e9 1b             	shr    $0x1b,%ecx
  801619:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80161c:	83 e2 1f             	and    $0x1f,%edx
  80161f:	29 ca                	sub    %ecx,%edx
  801621:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801625:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801629:	83 c0 01             	add    $0x1,%eax
  80162c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80162f:	83 c7 01             	add    $0x1,%edi
  801632:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801635:	75 c2                	jne    8015f9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801637:	8b 45 10             	mov    0x10(%ebp),%eax
  80163a:	eb 05                	jmp    801641 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80163c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801641:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801644:	5b                   	pop    %ebx
  801645:	5e                   	pop    %esi
  801646:	5f                   	pop    %edi
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    

00801649 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	57                   	push   %edi
  80164d:	56                   	push   %esi
  80164e:	53                   	push   %ebx
  80164f:	83 ec 18             	sub    $0x18,%esp
  801652:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801655:	57                   	push   %edi
  801656:	e8 bb f6 ff ff       	call   800d16 <fd2data>
  80165b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	bb 00 00 00 00       	mov    $0x0,%ebx
  801665:	eb 3d                	jmp    8016a4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801667:	85 db                	test   %ebx,%ebx
  801669:	74 04                	je     80166f <devpipe_read+0x26>
				return i;
  80166b:	89 d8                	mov    %ebx,%eax
  80166d:	eb 44                	jmp    8016b3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80166f:	89 f2                	mov    %esi,%edx
  801671:	89 f8                	mov    %edi,%eax
  801673:	e8 e5 fe ff ff       	call   80155d <_pipeisclosed>
  801678:	85 c0                	test   %eax,%eax
  80167a:	75 32                	jne    8016ae <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80167c:	e8 75 f4 ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801681:	8b 06                	mov    (%esi),%eax
  801683:	3b 46 04             	cmp    0x4(%esi),%eax
  801686:	74 df                	je     801667 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801688:	99                   	cltd   
  801689:	c1 ea 1b             	shr    $0x1b,%edx
  80168c:	01 d0                	add    %edx,%eax
  80168e:	83 e0 1f             	and    $0x1f,%eax
  801691:	29 d0                	sub    %edx,%eax
  801693:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801698:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80169b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80169e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a1:	83 c3 01             	add    $0x1,%ebx
  8016a4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016a7:	75 d8                	jne    801681 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ac:	eb 05                	jmp    8016b3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016ae:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b6:	5b                   	pop    %ebx
  8016b7:	5e                   	pop    %esi
  8016b8:	5f                   	pop    %edi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	56                   	push   %esi
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c6:	50                   	push   %eax
  8016c7:	e8 61 f6 ff ff       	call   800d2d <fd_alloc>
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	89 c2                	mov    %eax,%edx
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	0f 88 2c 01 00 00    	js     801805 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016d9:	83 ec 04             	sub    $0x4,%esp
  8016dc:	68 07 04 00 00       	push   $0x407
  8016e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e4:	6a 00                	push   $0x0
  8016e6:	e8 2a f4 ff ff       	call   800b15 <sys_page_alloc>
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	89 c2                	mov    %eax,%edx
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	0f 88 0d 01 00 00    	js     801805 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fe:	50                   	push   %eax
  8016ff:	e8 29 f6 ff ff       	call   800d2d <fd_alloc>
  801704:	89 c3                	mov    %eax,%ebx
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	85 c0                	test   %eax,%eax
  80170b:	0f 88 e2 00 00 00    	js     8017f3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801711:	83 ec 04             	sub    $0x4,%esp
  801714:	68 07 04 00 00       	push   $0x407
  801719:	ff 75 f0             	pushl  -0x10(%ebp)
  80171c:	6a 00                	push   $0x0
  80171e:	e8 f2 f3 ff ff       	call   800b15 <sys_page_alloc>
  801723:	89 c3                	mov    %eax,%ebx
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	85 c0                	test   %eax,%eax
  80172a:	0f 88 c3 00 00 00    	js     8017f3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801730:	83 ec 0c             	sub    $0xc,%esp
  801733:	ff 75 f4             	pushl  -0xc(%ebp)
  801736:	e8 db f5 ff ff       	call   800d16 <fd2data>
  80173b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80173d:	83 c4 0c             	add    $0xc,%esp
  801740:	68 07 04 00 00       	push   $0x407
  801745:	50                   	push   %eax
  801746:	6a 00                	push   $0x0
  801748:	e8 c8 f3 ff ff       	call   800b15 <sys_page_alloc>
  80174d:	89 c3                	mov    %eax,%ebx
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	85 c0                	test   %eax,%eax
  801754:	0f 88 89 00 00 00    	js     8017e3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80175a:	83 ec 0c             	sub    $0xc,%esp
  80175d:	ff 75 f0             	pushl  -0x10(%ebp)
  801760:	e8 b1 f5 ff ff       	call   800d16 <fd2data>
  801765:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80176c:	50                   	push   %eax
  80176d:	6a 00                	push   $0x0
  80176f:	56                   	push   %esi
  801770:	6a 00                	push   $0x0
  801772:	e8 e1 f3 ff ff       	call   800b58 <sys_page_map>
  801777:	89 c3                	mov    %eax,%ebx
  801779:	83 c4 20             	add    $0x20,%esp
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 55                	js     8017d5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801780:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801789:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80178b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801795:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80179b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017aa:	83 ec 0c             	sub    $0xc,%esp
  8017ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b0:	e8 51 f5 ff ff       	call   800d06 <fd2num>
  8017b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017ba:	83 c4 04             	add    $0x4,%esp
  8017bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c0:	e8 41 f5 ff ff       	call   800d06 <fd2num>
  8017c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d3:	eb 30                	jmp    801805 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017d5:	83 ec 08             	sub    $0x8,%esp
  8017d8:	56                   	push   %esi
  8017d9:	6a 00                	push   $0x0
  8017db:	e8 ba f3 ff ff       	call   800b9a <sys_page_unmap>
  8017e0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e9:	6a 00                	push   $0x0
  8017eb:	e8 aa f3 ff ff       	call   800b9a <sys_page_unmap>
  8017f0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017f3:	83 ec 08             	sub    $0x8,%esp
  8017f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f9:	6a 00                	push   $0x0
  8017fb:	e8 9a f3 ff ff       	call   800b9a <sys_page_unmap>
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801805:	89 d0                	mov    %edx,%eax
  801807:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5e                   	pop    %esi
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    

0080180e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801814:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801817:	50                   	push   %eax
  801818:	ff 75 08             	pushl  0x8(%ebp)
  80181b:	e8 5c f5 ff ff       	call   800d7c <fd_lookup>
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	85 c0                	test   %eax,%eax
  801825:	78 18                	js     80183f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801827:	83 ec 0c             	sub    $0xc,%esp
  80182a:	ff 75 f4             	pushl  -0xc(%ebp)
  80182d:	e8 e4 f4 ff ff       	call   800d16 <fd2data>
	return _pipeisclosed(fd, p);
  801832:	89 c2                	mov    %eax,%edx
  801834:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801837:	e8 21 fd ff ff       	call   80155d <_pipeisclosed>
  80183c:	83 c4 10             	add    $0x10,%esp
}
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801844:	b8 00 00 00 00       	mov    $0x0,%eax
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    

0080184b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801851:	68 88 22 80 00       	push   $0x802288
  801856:	ff 75 0c             	pushl  0xc(%ebp)
  801859:	e8 b4 ee ff ff       	call   800712 <strcpy>
	return 0;
}
  80185e:	b8 00 00 00 00       	mov    $0x0,%eax
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	57                   	push   %edi
  801869:	56                   	push   %esi
  80186a:	53                   	push   %ebx
  80186b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801871:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801876:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80187c:	eb 2d                	jmp    8018ab <devcons_write+0x46>
		m = n - tot;
  80187e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801881:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801883:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801886:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80188b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80188e:	83 ec 04             	sub    $0x4,%esp
  801891:	53                   	push   %ebx
  801892:	03 45 0c             	add    0xc(%ebp),%eax
  801895:	50                   	push   %eax
  801896:	57                   	push   %edi
  801897:	e8 08 f0 ff ff       	call   8008a4 <memmove>
		sys_cputs(buf, m);
  80189c:	83 c4 08             	add    $0x8,%esp
  80189f:	53                   	push   %ebx
  8018a0:	57                   	push   %edi
  8018a1:	e8 b3 f1 ff ff       	call   800a59 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018a6:	01 de                	add    %ebx,%esi
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	89 f0                	mov    %esi,%eax
  8018ad:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018b0:	72 cc                	jb     80187e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b5:	5b                   	pop    %ebx
  8018b6:	5e                   	pop    %esi
  8018b7:	5f                   	pop    %edi
  8018b8:	5d                   	pop    %ebp
  8018b9:	c3                   	ret    

008018ba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	83 ec 08             	sub    $0x8,%esp
  8018c0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018c9:	74 2a                	je     8018f5 <devcons_read+0x3b>
  8018cb:	eb 05                	jmp    8018d2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018cd:	e8 24 f2 ff ff       	call   800af6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018d2:	e8 a0 f1 ff ff       	call   800a77 <sys_cgetc>
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	74 f2                	je     8018cd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	78 16                	js     8018f5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018df:	83 f8 04             	cmp    $0x4,%eax
  8018e2:	74 0c                	je     8018f0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8018e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e7:	88 02                	mov    %al,(%edx)
	return 1;
  8018e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ee:	eb 05                	jmp    8018f5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018f0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801903:	6a 01                	push   $0x1
  801905:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801908:	50                   	push   %eax
  801909:	e8 4b f1 ff ff       	call   800a59 <sys_cputs>
}
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	c9                   	leave  
  801912:	c3                   	ret    

00801913 <getchar>:

int
getchar(void)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801919:	6a 01                	push   $0x1
  80191b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80191e:	50                   	push   %eax
  80191f:	6a 00                	push   $0x0
  801921:	e8 bc f6 ff ff       	call   800fe2 <read>
	if (r < 0)
  801926:	83 c4 10             	add    $0x10,%esp
  801929:	85 c0                	test   %eax,%eax
  80192b:	78 0f                	js     80193c <getchar+0x29>
		return r;
	if (r < 1)
  80192d:	85 c0                	test   %eax,%eax
  80192f:	7e 06                	jle    801937 <getchar+0x24>
		return -E_EOF;
	return c;
  801931:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801935:	eb 05                	jmp    80193c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801937:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801944:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801947:	50                   	push   %eax
  801948:	ff 75 08             	pushl  0x8(%ebp)
  80194b:	e8 2c f4 ff ff       	call   800d7c <fd_lookup>
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	85 c0                	test   %eax,%eax
  801955:	78 11                	js     801968 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801960:	39 10                	cmp    %edx,(%eax)
  801962:	0f 94 c0             	sete   %al
  801965:	0f b6 c0             	movzbl %al,%eax
}
  801968:	c9                   	leave  
  801969:	c3                   	ret    

0080196a <opencons>:

int
opencons(void)
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801970:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801973:	50                   	push   %eax
  801974:	e8 b4 f3 ff ff       	call   800d2d <fd_alloc>
  801979:	83 c4 10             	add    $0x10,%esp
		return r;
  80197c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 3e                	js     8019c0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801982:	83 ec 04             	sub    $0x4,%esp
  801985:	68 07 04 00 00       	push   $0x407
  80198a:	ff 75 f4             	pushl  -0xc(%ebp)
  80198d:	6a 00                	push   $0x0
  80198f:	e8 81 f1 ff ff       	call   800b15 <sys_page_alloc>
  801994:	83 c4 10             	add    $0x10,%esp
		return r;
  801997:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 23                	js     8019c0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80199d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	50                   	push   %eax
  8019b6:	e8 4b f3 ff ff       	call   800d06 <fd2num>
  8019bb:	89 c2                	mov    %eax,%edx
  8019bd:	83 c4 10             	add    $0x10,%esp
}
  8019c0:	89 d0                	mov    %edx,%eax
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019c9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019cc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019d2:	e8 00 f1 ff ff       	call   800ad7 <sys_getenvid>
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 75 0c             	pushl  0xc(%ebp)
  8019dd:	ff 75 08             	pushl  0x8(%ebp)
  8019e0:	56                   	push   %esi
  8019e1:	50                   	push   %eax
  8019e2:	68 94 22 80 00       	push   $0x802294
  8019e7:	e8 a1 e7 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019ec:	83 c4 18             	add    $0x18,%esp
  8019ef:	53                   	push   %ebx
  8019f0:	ff 75 10             	pushl  0x10(%ebp)
  8019f3:	e8 44 e7 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  8019f8:	c7 04 24 81 22 80 00 	movl   $0x802281,(%esp)
  8019ff:	e8 89 e7 ff ff       	call   80018d <cprintf>
  801a04:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a07:	cc                   	int3   
  801a08:	eb fd                	jmp    801a07 <_panic+0x43>

00801a0a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	56                   	push   %esi
  801a0e:	53                   	push   %ebx
  801a0f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801a18:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801a1a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a1f:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	50                   	push   %eax
  801a26:	e8 9a f2 ff ff       	call   800cc5 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	85 f6                	test   %esi,%esi
  801a30:	74 14                	je     801a46 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801a32:	ba 00 00 00 00       	mov    $0x0,%edx
  801a37:	85 c0                	test   %eax,%eax
  801a39:	78 09                	js     801a44 <ipc_recv+0x3a>
  801a3b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a41:	8b 52 74             	mov    0x74(%edx),%edx
  801a44:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801a46:	85 db                	test   %ebx,%ebx
  801a48:	74 14                	je     801a5e <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801a4a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	78 09                	js     801a5c <ipc_recv+0x52>
  801a53:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a59:	8b 52 78             	mov    0x78(%edx),%edx
  801a5c:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	78 08                	js     801a6a <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801a62:	a1 04 40 80 00       	mov    0x804004,%eax
  801a67:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5e                   	pop    %esi
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    

00801a71 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	57                   	push   %edi
  801a75:	56                   	push   %esi
  801a76:	53                   	push   %ebx
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801a83:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801a85:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a8a:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801a8d:	ff 75 14             	pushl  0x14(%ebp)
  801a90:	53                   	push   %ebx
  801a91:	56                   	push   %esi
  801a92:	57                   	push   %edi
  801a93:	e8 0a f2 ff ff       	call   800ca2 <sys_ipc_try_send>

		if (err < 0) {
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	79 1e                	jns    801abd <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801a9f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa2:	75 07                	jne    801aab <ipc_send+0x3a>
				sys_yield();
  801aa4:	e8 4d f0 ff ff       	call   800af6 <sys_yield>
  801aa9:	eb e2                	jmp    801a8d <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801aab:	50                   	push   %eax
  801aac:	68 b8 22 80 00       	push   $0x8022b8
  801ab1:	6a 49                	push   $0x49
  801ab3:	68 c5 22 80 00       	push   $0x8022c5
  801ab8:	e8 07 ff ff ff       	call   8019c4 <_panic>
		}

	} while (err < 0);

}
  801abd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac0:	5b                   	pop    %ebx
  801ac1:	5e                   	pop    %esi
  801ac2:	5f                   	pop    %edi
  801ac3:	5d                   	pop    %ebp
  801ac4:	c3                   	ret    

00801ac5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac5:	55                   	push   %ebp
  801ac6:	89 e5                	mov    %esp,%ebp
  801ac8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801acb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ad3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad9:	8b 52 50             	mov    0x50(%edx),%edx
  801adc:	39 ca                	cmp    %ecx,%edx
  801ade:	75 0d                	jne    801aed <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ae3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ae8:	8b 40 48             	mov    0x48(%eax),%eax
  801aeb:	eb 0f                	jmp    801afc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aed:	83 c0 01             	add    $0x1,%eax
  801af0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af5:	75 d9                	jne    801ad0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801afc:	5d                   	pop    %ebp
  801afd:	c3                   	ret    

00801afe <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b04:	89 d0                	mov    %edx,%eax
  801b06:	c1 e8 16             	shr    $0x16,%eax
  801b09:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b10:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b15:	f6 c1 01             	test   $0x1,%cl
  801b18:	74 1d                	je     801b37 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b1a:	c1 ea 0c             	shr    $0xc,%edx
  801b1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b24:	f6 c2 01             	test   $0x1,%dl
  801b27:	74 0e                	je     801b37 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b29:	c1 ea 0c             	shr    $0xc,%edx
  801b2c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b33:	ef 
  801b34:	0f b7 c0             	movzwl %ax,%eax
}
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    
  801b39:	66 90                	xchg   %ax,%ax
  801b3b:	66 90                	xchg   %ax,%ax
  801b3d:	66 90                	xchg   %ax,%ax
  801b3f:	90                   	nop

00801b40 <__udivdi3>:
  801b40:	55                   	push   %ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 1c             	sub    $0x1c,%esp
  801b47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b57:	85 f6                	test   %esi,%esi
  801b59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b5d:	89 ca                	mov    %ecx,%edx
  801b5f:	89 f8                	mov    %edi,%eax
  801b61:	75 3d                	jne    801ba0 <__udivdi3+0x60>
  801b63:	39 cf                	cmp    %ecx,%edi
  801b65:	0f 87 c5 00 00 00    	ja     801c30 <__udivdi3+0xf0>
  801b6b:	85 ff                	test   %edi,%edi
  801b6d:	89 fd                	mov    %edi,%ebp
  801b6f:	75 0b                	jne    801b7c <__udivdi3+0x3c>
  801b71:	b8 01 00 00 00       	mov    $0x1,%eax
  801b76:	31 d2                	xor    %edx,%edx
  801b78:	f7 f7                	div    %edi
  801b7a:	89 c5                	mov    %eax,%ebp
  801b7c:	89 c8                	mov    %ecx,%eax
  801b7e:	31 d2                	xor    %edx,%edx
  801b80:	f7 f5                	div    %ebp
  801b82:	89 c1                	mov    %eax,%ecx
  801b84:	89 d8                	mov    %ebx,%eax
  801b86:	89 cf                	mov    %ecx,%edi
  801b88:	f7 f5                	div    %ebp
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	89 fa                	mov    %edi,%edx
  801b90:	83 c4 1c             	add    $0x1c,%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
  801b98:	90                   	nop
  801b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba0:	39 ce                	cmp    %ecx,%esi
  801ba2:	77 74                	ja     801c18 <__udivdi3+0xd8>
  801ba4:	0f bd fe             	bsr    %esi,%edi
  801ba7:	83 f7 1f             	xor    $0x1f,%edi
  801baa:	0f 84 98 00 00 00    	je     801c48 <__udivdi3+0x108>
  801bb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bb5:	89 f9                	mov    %edi,%ecx
  801bb7:	89 c5                	mov    %eax,%ebp
  801bb9:	29 fb                	sub    %edi,%ebx
  801bbb:	d3 e6                	shl    %cl,%esi
  801bbd:	89 d9                	mov    %ebx,%ecx
  801bbf:	d3 ed                	shr    %cl,%ebp
  801bc1:	89 f9                	mov    %edi,%ecx
  801bc3:	d3 e0                	shl    %cl,%eax
  801bc5:	09 ee                	or     %ebp,%esi
  801bc7:	89 d9                	mov    %ebx,%ecx
  801bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcd:	89 d5                	mov    %edx,%ebp
  801bcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bd3:	d3 ed                	shr    %cl,%ebp
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	d3 e2                	shl    %cl,%edx
  801bd9:	89 d9                	mov    %ebx,%ecx
  801bdb:	d3 e8                	shr    %cl,%eax
  801bdd:	09 c2                	or     %eax,%edx
  801bdf:	89 d0                	mov    %edx,%eax
  801be1:	89 ea                	mov    %ebp,%edx
  801be3:	f7 f6                	div    %esi
  801be5:	89 d5                	mov    %edx,%ebp
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	f7 64 24 0c          	mull   0xc(%esp)
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	72 10                	jb     801c01 <__udivdi3+0xc1>
  801bf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e6                	shl    %cl,%esi
  801bf9:	39 c6                	cmp    %eax,%esi
  801bfb:	73 07                	jae    801c04 <__udivdi3+0xc4>
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	75 03                	jne    801c04 <__udivdi3+0xc4>
  801c01:	83 eb 01             	sub    $0x1,%ebx
  801c04:	31 ff                	xor    %edi,%edi
  801c06:	89 d8                	mov    %ebx,%eax
  801c08:	89 fa                	mov    %edi,%edx
  801c0a:	83 c4 1c             	add    $0x1c,%esp
  801c0d:	5b                   	pop    %ebx
  801c0e:	5e                   	pop    %esi
  801c0f:	5f                   	pop    %edi
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    
  801c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c18:	31 ff                	xor    %edi,%edi
  801c1a:	31 db                	xor    %ebx,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 d8                	mov    %ebx,%eax
  801c32:	f7 f7                	div    %edi
  801c34:	31 ff                	xor    %edi,%edi
  801c36:	89 c3                	mov    %eax,%ebx
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	89 fa                	mov    %edi,%edx
  801c3c:	83 c4 1c             	add    $0x1c,%esp
  801c3f:	5b                   	pop    %ebx
  801c40:	5e                   	pop    %esi
  801c41:	5f                   	pop    %edi
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    
  801c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c48:	39 ce                	cmp    %ecx,%esi
  801c4a:	72 0c                	jb     801c58 <__udivdi3+0x118>
  801c4c:	31 db                	xor    %ebx,%ebx
  801c4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c52:	0f 87 34 ff ff ff    	ja     801b8c <__udivdi3+0x4c>
  801c58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c5d:	e9 2a ff ff ff       	jmp    801b8c <__udivdi3+0x4c>
  801c62:	66 90                	xchg   %ax,%ax
  801c64:	66 90                	xchg   %ax,%ax
  801c66:	66 90                	xchg   %ax,%ax
  801c68:	66 90                	xchg   %ax,%ax
  801c6a:	66 90                	xchg   %ax,%ax
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__umoddi3>:
  801c70:	55                   	push   %ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	83 ec 1c             	sub    $0x1c,%esp
  801c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c87:	85 d2                	test   %edx,%edx
  801c89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c91:	89 f3                	mov    %esi,%ebx
  801c93:	89 3c 24             	mov    %edi,(%esp)
  801c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9a:	75 1c                	jne    801cb8 <__umoddi3+0x48>
  801c9c:	39 f7                	cmp    %esi,%edi
  801c9e:	76 50                	jbe    801cf0 <__umoddi3+0x80>
  801ca0:	89 c8                	mov    %ecx,%eax
  801ca2:	89 f2                	mov    %esi,%edx
  801ca4:	f7 f7                	div    %edi
  801ca6:	89 d0                	mov    %edx,%eax
  801ca8:	31 d2                	xor    %edx,%edx
  801caa:	83 c4 1c             	add    $0x1c,%esp
  801cad:	5b                   	pop    %ebx
  801cae:	5e                   	pop    %esi
  801caf:	5f                   	pop    %edi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    
  801cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	89 d0                	mov    %edx,%eax
  801cbc:	77 52                	ja     801d10 <__umoddi3+0xa0>
  801cbe:	0f bd ea             	bsr    %edx,%ebp
  801cc1:	83 f5 1f             	xor    $0x1f,%ebp
  801cc4:	75 5a                	jne    801d20 <__umoddi3+0xb0>
  801cc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cca:	0f 82 e0 00 00 00    	jb     801db0 <__umoddi3+0x140>
  801cd0:	39 0c 24             	cmp    %ecx,(%esp)
  801cd3:	0f 86 d7 00 00 00    	jbe    801db0 <__umoddi3+0x140>
  801cd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ce1:	83 c4 1c             	add    $0x1c,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	85 ff                	test   %edi,%edi
  801cf2:	89 fd                	mov    %edi,%ebp
  801cf4:	75 0b                	jne    801d01 <__umoddi3+0x91>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f7                	div    %edi
  801cff:	89 c5                	mov    %eax,%ebp
  801d01:	89 f0                	mov    %esi,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f5                	div    %ebp
  801d07:	89 c8                	mov    %ecx,%eax
  801d09:	f7 f5                	div    %ebp
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	eb 99                	jmp    801ca8 <__umoddi3+0x38>
  801d0f:	90                   	nop
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	83 c4 1c             	add    $0x1c,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5f                   	pop    %edi
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	8b 34 24             	mov    (%esp),%esi
  801d23:	bf 20 00 00 00       	mov    $0x20,%edi
  801d28:	89 e9                	mov    %ebp,%ecx
  801d2a:	29 ef                	sub    %ebp,%edi
  801d2c:	d3 e0                	shl    %cl,%eax
  801d2e:	89 f9                	mov    %edi,%ecx
  801d30:	89 f2                	mov    %esi,%edx
  801d32:	d3 ea                	shr    %cl,%edx
  801d34:	89 e9                	mov    %ebp,%ecx
  801d36:	09 c2                	or     %eax,%edx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 14 24             	mov    %edx,(%esp)
  801d3d:	89 f2                	mov    %esi,%edx
  801d3f:	d3 e2                	shl    %cl,%edx
  801d41:	89 f9                	mov    %edi,%ecx
  801d43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	89 e9                	mov    %ebp,%ecx
  801d4f:	89 c6                	mov    %eax,%esi
  801d51:	d3 e3                	shl    %cl,%ebx
  801d53:	89 f9                	mov    %edi,%ecx
  801d55:	89 d0                	mov    %edx,%eax
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	09 d8                	or     %ebx,%eax
  801d5d:	89 d3                	mov    %edx,%ebx
  801d5f:	89 f2                	mov    %esi,%edx
  801d61:	f7 34 24             	divl   (%esp)
  801d64:	89 d6                	mov    %edx,%esi
  801d66:	d3 e3                	shl    %cl,%ebx
  801d68:	f7 64 24 04          	mull   0x4(%esp)
  801d6c:	39 d6                	cmp    %edx,%esi
  801d6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d72:	89 d1                	mov    %edx,%ecx
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	72 08                	jb     801d80 <__umoddi3+0x110>
  801d78:	75 11                	jne    801d8b <__umoddi3+0x11b>
  801d7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d7e:	73 0b                	jae    801d8b <__umoddi3+0x11b>
  801d80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d84:	1b 14 24             	sbb    (%esp),%edx
  801d87:	89 d1                	mov    %edx,%ecx
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d8f:	29 da                	sub    %ebx,%edx
  801d91:	19 ce                	sbb    %ecx,%esi
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 f0                	mov    %esi,%eax
  801d97:	d3 e0                	shl    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	d3 ea                	shr    %cl,%edx
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	d3 ee                	shr    %cl,%esi
  801da1:	09 d0                	or     %edx,%eax
  801da3:	89 f2                	mov    %esi,%edx
  801da5:	83 c4 1c             	add    $0x1c,%esp
  801da8:	5b                   	pop    %ebx
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
  801db0:	29 f9                	sub    %edi,%ecx
  801db2:	19 d6                	sbb    %edx,%esi
  801db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dbc:	e9 18 ff ff ff       	jmp    801cd9 <__umoddi3+0x69>
