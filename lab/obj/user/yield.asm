
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
  80003a:	a1 08 40 80 00       	mov    0x804008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 00 23 80 00       	push   $0x802300
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 9c 0a 00 00       	call   800af6 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 08 40 80 00       	mov    0x804008,%eax
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
  800067:	68 20 23 80 00       	push   $0x802320
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
  80007c:	a1 08 40 80 00       	mov    0x804008,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 4c 23 80 00       	push   $0x80234c
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
  8000b7:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8000e6:	e8 89 0e 00 00       	call   800f74 <close_all>
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
  8001f0:	e8 7b 1e 00 00       	call   802070 <__udivdi3>
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
  800233:	e8 68 1f 00 00       	call   8021a0 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 75 23 80 00 	movsbl 0x802375(%eax),%eax
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
  800337:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
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
  8003fb:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  800402:	85 d2                	test   %edx,%edx
  800404:	75 18                	jne    80041e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800406:	50                   	push   %eax
  800407:	68 8d 23 80 00       	push   $0x80238d
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
  80041f:	68 55 27 80 00       	push   $0x802755
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
  800443:	b8 86 23 80 00       	mov    $0x802386,%eax
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
  800abe:	68 7f 26 80 00       	push   $0x80267f
  800ac3:	6a 23                	push   $0x23
  800ac5:	68 9c 26 80 00       	push   $0x80269c
  800aca:	e8 1e 14 00 00       	call   801eed <_panic>

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
  800b3f:	68 7f 26 80 00       	push   $0x80267f
  800b44:	6a 23                	push   $0x23
  800b46:	68 9c 26 80 00       	push   $0x80269c
  800b4b:	e8 9d 13 00 00       	call   801eed <_panic>

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
  800b81:	68 7f 26 80 00       	push   $0x80267f
  800b86:	6a 23                	push   $0x23
  800b88:	68 9c 26 80 00       	push   $0x80269c
  800b8d:	e8 5b 13 00 00       	call   801eed <_panic>

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
  800bc3:	68 7f 26 80 00       	push   $0x80267f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 9c 26 80 00       	push   $0x80269c
  800bcf:	e8 19 13 00 00       	call   801eed <_panic>

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
  800c05:	68 7f 26 80 00       	push   $0x80267f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 9c 26 80 00       	push   $0x80269c
  800c11:	e8 d7 12 00 00       	call   801eed <_panic>

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
  800c47:	68 7f 26 80 00       	push   $0x80267f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 9c 26 80 00       	push   $0x80269c
  800c53:	e8 95 12 00 00       	call   801eed <_panic>

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
  800c89:	68 7f 26 80 00       	push   $0x80267f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 9c 26 80 00       	push   $0x80269c
  800c95:	e8 53 12 00 00       	call   801eed <_panic>

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
  800ced:	68 7f 26 80 00       	push   $0x80267f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 9c 26 80 00       	push   $0x80269c
  800cf9:	e8 ef 11 00 00       	call   801eed <_panic>

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

00800d06 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d11:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d16:	89 d1                	mov    %edx,%ecx
  800d18:	89 d3                	mov    %edx,%ebx
  800d1a:	89 d7                	mov    %edx,%edi
  800d1c:	89 d6                	mov    %edx,%esi
  800d1e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d33:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 df                	mov    %ebx,%edi
  800d40:	89 de                	mov    %ebx,%esi
  800d42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 0f                	push   $0xf
  800d4e:	68 7f 26 80 00       	push   $0x80267f
  800d53:	6a 23                	push   $0x23
  800d55:	68 9c 26 80 00       	push   $0x80269c
  800d5a:	e8 8e 11 00 00       	call   801eed <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d75:	b8 10 00 00 00       	mov    $0x10,%eax
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	89 df                	mov    %ebx,%edi
  800d82:	89 de                	mov    %ebx,%esi
  800d84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 10                	push   $0x10
  800d90:	68 7f 26 80 00       	push   $0x80267f
  800d95:	6a 23                	push   $0x23
  800d97:	68 9c 26 80 00       	push   $0x80269c
  800d9c:	e8 4c 11 00 00       	call   801eed <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
  800daf:	05 00 00 00 30       	add    $0x30000000,%eax
  800db4:	c1 e8 0c             	shr    $0xc,%eax
}
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbf:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dc9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ddb:	89 c2                	mov    %eax,%edx
  800ddd:	c1 ea 16             	shr    $0x16,%edx
  800de0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de7:	f6 c2 01             	test   $0x1,%dl
  800dea:	74 11                	je     800dfd <fd_alloc+0x2d>
  800dec:	89 c2                	mov    %eax,%edx
  800dee:	c1 ea 0c             	shr    $0xc,%edx
  800df1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df8:	f6 c2 01             	test   $0x1,%dl
  800dfb:	75 09                	jne    800e06 <fd_alloc+0x36>
			*fd_store = fd;
  800dfd:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dff:	b8 00 00 00 00       	mov    $0x0,%eax
  800e04:	eb 17                	jmp    800e1d <fd_alloc+0x4d>
  800e06:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e0b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e10:	75 c9                	jne    800ddb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e12:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e18:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e25:	83 f8 1f             	cmp    $0x1f,%eax
  800e28:	77 36                	ja     800e60 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e2a:	c1 e0 0c             	shl    $0xc,%eax
  800e2d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e32:	89 c2                	mov    %eax,%edx
  800e34:	c1 ea 16             	shr    $0x16,%edx
  800e37:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e3e:	f6 c2 01             	test   $0x1,%dl
  800e41:	74 24                	je     800e67 <fd_lookup+0x48>
  800e43:	89 c2                	mov    %eax,%edx
  800e45:	c1 ea 0c             	shr    $0xc,%edx
  800e48:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4f:	f6 c2 01             	test   $0x1,%dl
  800e52:	74 1a                	je     800e6e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e57:	89 02                	mov    %eax,(%edx)
	return 0;
  800e59:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5e:	eb 13                	jmp    800e73 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e60:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e65:	eb 0c                	jmp    800e73 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e6c:	eb 05                	jmp    800e73 <fd_lookup+0x54>
  800e6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7e:	ba 28 27 80 00       	mov    $0x802728,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e83:	eb 13                	jmp    800e98 <dev_lookup+0x23>
  800e85:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e88:	39 08                	cmp    %ecx,(%eax)
  800e8a:	75 0c                	jne    800e98 <dev_lookup+0x23>
			*dev = devtab[i];
  800e8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	eb 2e                	jmp    800ec6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e98:	8b 02                	mov    (%edx),%eax
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	75 e7                	jne    800e85 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e9e:	a1 08 40 80 00       	mov    0x804008,%eax
  800ea3:	8b 40 48             	mov    0x48(%eax),%eax
  800ea6:	83 ec 04             	sub    $0x4,%esp
  800ea9:	51                   	push   %ecx
  800eaa:	50                   	push   %eax
  800eab:	68 ac 26 80 00       	push   $0x8026ac
  800eb0:	e8 d8 f2 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	83 ec 10             	sub    $0x10,%esp
  800ed0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ed3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ed6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed9:	50                   	push   %eax
  800eda:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ee0:	c1 e8 0c             	shr    $0xc,%eax
  800ee3:	50                   	push   %eax
  800ee4:	e8 36 ff ff ff       	call   800e1f <fd_lookup>
  800ee9:	83 c4 08             	add    $0x8,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	78 05                	js     800ef5 <fd_close+0x2d>
	    || fd != fd2)
  800ef0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ef3:	74 0c                	je     800f01 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ef5:	84 db                	test   %bl,%bl
  800ef7:	ba 00 00 00 00       	mov    $0x0,%edx
  800efc:	0f 44 c2             	cmove  %edx,%eax
  800eff:	eb 41                	jmp    800f42 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f01:	83 ec 08             	sub    $0x8,%esp
  800f04:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f07:	50                   	push   %eax
  800f08:	ff 36                	pushl  (%esi)
  800f0a:	e8 66 ff ff ff       	call   800e75 <dev_lookup>
  800f0f:	89 c3                	mov    %eax,%ebx
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	78 1a                	js     800f32 <fd_close+0x6a>
		if (dev->dev_close)
  800f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f1e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f23:	85 c0                	test   %eax,%eax
  800f25:	74 0b                	je     800f32 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	56                   	push   %esi
  800f2b:	ff d0                	call   *%eax
  800f2d:	89 c3                	mov    %eax,%ebx
  800f2f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f32:	83 ec 08             	sub    $0x8,%esp
  800f35:	56                   	push   %esi
  800f36:	6a 00                	push   $0x0
  800f38:	e8 5d fc ff ff       	call   800b9a <sys_page_unmap>
	return r;
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	89 d8                	mov    %ebx,%eax
}
  800f42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f52:	50                   	push   %eax
  800f53:	ff 75 08             	pushl  0x8(%ebp)
  800f56:	e8 c4 fe ff ff       	call   800e1f <fd_lookup>
  800f5b:	83 c4 08             	add    $0x8,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	78 10                	js     800f72 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f62:	83 ec 08             	sub    $0x8,%esp
  800f65:	6a 01                	push   $0x1
  800f67:	ff 75 f4             	pushl  -0xc(%ebp)
  800f6a:	e8 59 ff ff ff       	call   800ec8 <fd_close>
  800f6f:	83 c4 10             	add    $0x10,%esp
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <close_all>:

void
close_all(void)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	53                   	push   %ebx
  800f78:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f7b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	53                   	push   %ebx
  800f84:	e8 c0 ff ff ff       	call   800f49 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f89:	83 c3 01             	add    $0x1,%ebx
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	83 fb 20             	cmp    $0x20,%ebx
  800f92:	75 ec                	jne    800f80 <close_all+0xc>
		close(i);
}
  800f94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f97:	c9                   	leave  
  800f98:	c3                   	ret    

00800f99 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	57                   	push   %edi
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 2c             	sub    $0x2c,%esp
  800fa2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fa5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fa8:	50                   	push   %eax
  800fa9:	ff 75 08             	pushl  0x8(%ebp)
  800fac:	e8 6e fe ff ff       	call   800e1f <fd_lookup>
  800fb1:	83 c4 08             	add    $0x8,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	0f 88 c1 00 00 00    	js     80107d <dup+0xe4>
		return r;
	close(newfdnum);
  800fbc:	83 ec 0c             	sub    $0xc,%esp
  800fbf:	56                   	push   %esi
  800fc0:	e8 84 ff ff ff       	call   800f49 <close>

	newfd = INDEX2FD(newfdnum);
  800fc5:	89 f3                	mov    %esi,%ebx
  800fc7:	c1 e3 0c             	shl    $0xc,%ebx
  800fca:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fd0:	83 c4 04             	add    $0x4,%esp
  800fd3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd6:	e8 de fd ff ff       	call   800db9 <fd2data>
  800fdb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fdd:	89 1c 24             	mov    %ebx,(%esp)
  800fe0:	e8 d4 fd ff ff       	call   800db9 <fd2data>
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800feb:	89 f8                	mov    %edi,%eax
  800fed:	c1 e8 16             	shr    $0x16,%eax
  800ff0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff7:	a8 01                	test   $0x1,%al
  800ff9:	74 37                	je     801032 <dup+0x99>
  800ffb:	89 f8                	mov    %edi,%eax
  800ffd:	c1 e8 0c             	shr    $0xc,%eax
  801000:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801007:	f6 c2 01             	test   $0x1,%dl
  80100a:	74 26                	je     801032 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80100c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801013:	83 ec 0c             	sub    $0xc,%esp
  801016:	25 07 0e 00 00       	and    $0xe07,%eax
  80101b:	50                   	push   %eax
  80101c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80101f:	6a 00                	push   $0x0
  801021:	57                   	push   %edi
  801022:	6a 00                	push   $0x0
  801024:	e8 2f fb ff ff       	call   800b58 <sys_page_map>
  801029:	89 c7                	mov    %eax,%edi
  80102b:	83 c4 20             	add    $0x20,%esp
  80102e:	85 c0                	test   %eax,%eax
  801030:	78 2e                	js     801060 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801032:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801035:	89 d0                	mov    %edx,%eax
  801037:	c1 e8 0c             	shr    $0xc,%eax
  80103a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	25 07 0e 00 00       	and    $0xe07,%eax
  801049:	50                   	push   %eax
  80104a:	53                   	push   %ebx
  80104b:	6a 00                	push   $0x0
  80104d:	52                   	push   %edx
  80104e:	6a 00                	push   $0x0
  801050:	e8 03 fb ff ff       	call   800b58 <sys_page_map>
  801055:	89 c7                	mov    %eax,%edi
  801057:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80105a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80105c:	85 ff                	test   %edi,%edi
  80105e:	79 1d                	jns    80107d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	53                   	push   %ebx
  801064:	6a 00                	push   $0x0
  801066:	e8 2f fb ff ff       	call   800b9a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80106b:	83 c4 08             	add    $0x8,%esp
  80106e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801071:	6a 00                	push   $0x0
  801073:	e8 22 fb ff ff       	call   800b9a <sys_page_unmap>
	return r;
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	89 f8                	mov    %edi,%eax
}
  80107d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	53                   	push   %ebx
  801089:	83 ec 14             	sub    $0x14,%esp
  80108c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80108f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801092:	50                   	push   %eax
  801093:	53                   	push   %ebx
  801094:	e8 86 fd ff ff       	call   800e1f <fd_lookup>
  801099:	83 c4 08             	add    $0x8,%esp
  80109c:	89 c2                	mov    %eax,%edx
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 6d                	js     80110f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a2:	83 ec 08             	sub    $0x8,%esp
  8010a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a8:	50                   	push   %eax
  8010a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ac:	ff 30                	pushl  (%eax)
  8010ae:	e8 c2 fd ff ff       	call   800e75 <dev_lookup>
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 4c                	js     801106 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010bd:	8b 42 08             	mov    0x8(%edx),%eax
  8010c0:	83 e0 03             	and    $0x3,%eax
  8010c3:	83 f8 01             	cmp    $0x1,%eax
  8010c6:	75 21                	jne    8010e9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010c8:	a1 08 40 80 00       	mov    0x804008,%eax
  8010cd:	8b 40 48             	mov    0x48(%eax),%eax
  8010d0:	83 ec 04             	sub    $0x4,%esp
  8010d3:	53                   	push   %ebx
  8010d4:	50                   	push   %eax
  8010d5:	68 ed 26 80 00       	push   $0x8026ed
  8010da:	e8 ae f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  8010df:	83 c4 10             	add    $0x10,%esp
  8010e2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010e7:	eb 26                	jmp    80110f <read+0x8a>
	}
	if (!dev->dev_read)
  8010e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ec:	8b 40 08             	mov    0x8(%eax),%eax
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	74 17                	je     80110a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010f3:	83 ec 04             	sub    $0x4,%esp
  8010f6:	ff 75 10             	pushl  0x10(%ebp)
  8010f9:	ff 75 0c             	pushl  0xc(%ebp)
  8010fc:	52                   	push   %edx
  8010fd:	ff d0                	call   *%eax
  8010ff:	89 c2                	mov    %eax,%edx
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	eb 09                	jmp    80110f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801106:	89 c2                	mov    %eax,%edx
  801108:	eb 05                	jmp    80110f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80110a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80110f:	89 d0                	mov    %edx,%eax
  801111:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801114:	c9                   	leave  
  801115:	c3                   	ret    

00801116 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	57                   	push   %edi
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
  80111c:	83 ec 0c             	sub    $0xc,%esp
  80111f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801122:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801125:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112a:	eb 21                	jmp    80114d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80112c:	83 ec 04             	sub    $0x4,%esp
  80112f:	89 f0                	mov    %esi,%eax
  801131:	29 d8                	sub    %ebx,%eax
  801133:	50                   	push   %eax
  801134:	89 d8                	mov    %ebx,%eax
  801136:	03 45 0c             	add    0xc(%ebp),%eax
  801139:	50                   	push   %eax
  80113a:	57                   	push   %edi
  80113b:	e8 45 ff ff ff       	call   801085 <read>
		if (m < 0)
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	85 c0                	test   %eax,%eax
  801145:	78 10                	js     801157 <readn+0x41>
			return m;
		if (m == 0)
  801147:	85 c0                	test   %eax,%eax
  801149:	74 0a                	je     801155 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80114b:	01 c3                	add    %eax,%ebx
  80114d:	39 f3                	cmp    %esi,%ebx
  80114f:	72 db                	jb     80112c <readn+0x16>
  801151:	89 d8                	mov    %ebx,%eax
  801153:	eb 02                	jmp    801157 <readn+0x41>
  801155:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801157:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115a:	5b                   	pop    %ebx
  80115b:	5e                   	pop    %esi
  80115c:	5f                   	pop    %edi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	53                   	push   %ebx
  801163:	83 ec 14             	sub    $0x14,%esp
  801166:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801169:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116c:	50                   	push   %eax
  80116d:	53                   	push   %ebx
  80116e:	e8 ac fc ff ff       	call   800e1f <fd_lookup>
  801173:	83 c4 08             	add    $0x8,%esp
  801176:	89 c2                	mov    %eax,%edx
  801178:	85 c0                	test   %eax,%eax
  80117a:	78 68                	js     8011e4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117c:	83 ec 08             	sub    $0x8,%esp
  80117f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801182:	50                   	push   %eax
  801183:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801186:	ff 30                	pushl  (%eax)
  801188:	e8 e8 fc ff ff       	call   800e75 <dev_lookup>
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	85 c0                	test   %eax,%eax
  801192:	78 47                	js     8011db <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801194:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801197:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80119b:	75 21                	jne    8011be <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80119d:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a2:	8b 40 48             	mov    0x48(%eax),%eax
  8011a5:	83 ec 04             	sub    $0x4,%esp
  8011a8:	53                   	push   %ebx
  8011a9:	50                   	push   %eax
  8011aa:	68 09 27 80 00       	push   $0x802709
  8011af:	e8 d9 ef ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011bc:	eb 26                	jmp    8011e4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c1:	8b 52 0c             	mov    0xc(%edx),%edx
  8011c4:	85 d2                	test   %edx,%edx
  8011c6:	74 17                	je     8011df <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011c8:	83 ec 04             	sub    $0x4,%esp
  8011cb:	ff 75 10             	pushl  0x10(%ebp)
  8011ce:	ff 75 0c             	pushl  0xc(%ebp)
  8011d1:	50                   	push   %eax
  8011d2:	ff d2                	call   *%edx
  8011d4:	89 c2                	mov    %eax,%edx
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	eb 09                	jmp    8011e4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	eb 05                	jmp    8011e4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011e4:	89 d0                	mov    %edx,%eax
  8011e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <seek>:

int
seek(int fdnum, off_t offset)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	ff 75 08             	pushl  0x8(%ebp)
  8011f8:	e8 22 fc ff ff       	call   800e1f <fd_lookup>
  8011fd:	83 c4 08             	add    $0x8,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 0e                	js     801212 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801204:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801207:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80120d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801212:	c9                   	leave  
  801213:	c3                   	ret    

00801214 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	53                   	push   %ebx
  801218:	83 ec 14             	sub    $0x14,%esp
  80121b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	53                   	push   %ebx
  801223:	e8 f7 fb ff ff       	call   800e1f <fd_lookup>
  801228:	83 c4 08             	add    $0x8,%esp
  80122b:	89 c2                	mov    %eax,%edx
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 65                	js     801296 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123b:	ff 30                	pushl  (%eax)
  80123d:	e8 33 fc ff ff       	call   800e75 <dev_lookup>
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	78 44                	js     80128d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801250:	75 21                	jne    801273 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801252:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801257:	8b 40 48             	mov    0x48(%eax),%eax
  80125a:	83 ec 04             	sub    $0x4,%esp
  80125d:	53                   	push   %ebx
  80125e:	50                   	push   %eax
  80125f:	68 cc 26 80 00       	push   $0x8026cc
  801264:	e8 24 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801271:	eb 23                	jmp    801296 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801273:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801276:	8b 52 18             	mov    0x18(%edx),%edx
  801279:	85 d2                	test   %edx,%edx
  80127b:	74 14                	je     801291 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	ff 75 0c             	pushl  0xc(%ebp)
  801283:	50                   	push   %eax
  801284:	ff d2                	call   *%edx
  801286:	89 c2                	mov    %eax,%edx
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	eb 09                	jmp    801296 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128d:	89 c2                	mov    %eax,%edx
  80128f:	eb 05                	jmp    801296 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801291:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801296:	89 d0                	mov    %edx,%eax
  801298:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 14             	sub    $0x14,%esp
  8012a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012aa:	50                   	push   %eax
  8012ab:	ff 75 08             	pushl  0x8(%ebp)
  8012ae:	e8 6c fb ff ff       	call   800e1f <fd_lookup>
  8012b3:	83 c4 08             	add    $0x8,%esp
  8012b6:	89 c2                	mov    %eax,%edx
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	78 58                	js     801314 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bc:	83 ec 08             	sub    $0x8,%esp
  8012bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c2:	50                   	push   %eax
  8012c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c6:	ff 30                	pushl  (%eax)
  8012c8:	e8 a8 fb ff ff       	call   800e75 <dev_lookup>
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 37                	js     80130b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012db:	74 32                	je     80130f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012dd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012e0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012e7:	00 00 00 
	stat->st_isdir = 0;
  8012ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012f1:	00 00 00 
	stat->st_dev = dev;
  8012f4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	53                   	push   %ebx
  8012fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801301:	ff 50 14             	call   *0x14(%eax)
  801304:	89 c2                	mov    %eax,%edx
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	eb 09                	jmp    801314 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130b:	89 c2                	mov    %eax,%edx
  80130d:	eb 05                	jmp    801314 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80130f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801314:	89 d0                	mov    %edx,%eax
  801316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	56                   	push   %esi
  80131f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	6a 00                	push   $0x0
  801325:	ff 75 08             	pushl  0x8(%ebp)
  801328:	e8 d6 01 00 00       	call   801503 <open>
  80132d:	89 c3                	mov    %eax,%ebx
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 1b                	js     801351 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	ff 75 0c             	pushl  0xc(%ebp)
  80133c:	50                   	push   %eax
  80133d:	e8 5b ff ff ff       	call   80129d <fstat>
  801342:	89 c6                	mov    %eax,%esi
	close(fd);
  801344:	89 1c 24             	mov    %ebx,(%esp)
  801347:	e8 fd fb ff ff       	call   800f49 <close>
	return r;
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	89 f0                	mov    %esi,%eax
}
  801351:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801354:	5b                   	pop    %ebx
  801355:	5e                   	pop    %esi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    

00801358 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	56                   	push   %esi
  80135c:	53                   	push   %ebx
  80135d:	89 c6                	mov    %eax,%esi
  80135f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801361:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801368:	75 12                	jne    80137c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	6a 01                	push   $0x1
  80136f:	e8 7a 0c 00 00       	call   801fee <ipc_find_env>
  801374:	a3 00 40 80 00       	mov    %eax,0x804000
  801379:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80137c:	6a 07                	push   $0x7
  80137e:	68 00 50 80 00       	push   $0x805000
  801383:	56                   	push   %esi
  801384:	ff 35 00 40 80 00    	pushl  0x804000
  80138a:	e8 0b 0c 00 00       	call   801f9a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80138f:	83 c4 0c             	add    $0xc,%esp
  801392:	6a 00                	push   $0x0
  801394:	53                   	push   %ebx
  801395:	6a 00                	push   $0x0
  801397:	e8 97 0b 00 00       	call   801f33 <ipc_recv>
}
  80139c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8013af:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c1:	b8 02 00 00 00       	mov    $0x2,%eax
  8013c6:	e8 8d ff ff ff       	call   801358 <fsipc>
}
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013de:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e3:	b8 06 00 00 00       	mov    $0x6,%eax
  8013e8:	e8 6b ff ff ff       	call   801358 <fsipc>
}
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    

008013ef <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 04             	sub    $0x4,%esp
  8013f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ff:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801404:	ba 00 00 00 00       	mov    $0x0,%edx
  801409:	b8 05 00 00 00       	mov    $0x5,%eax
  80140e:	e8 45 ff ff ff       	call   801358 <fsipc>
  801413:	85 c0                	test   %eax,%eax
  801415:	78 2c                	js     801443 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	68 00 50 80 00       	push   $0x805000
  80141f:	53                   	push   %ebx
  801420:	e8 ed f2 ff ff       	call   800712 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801425:	a1 80 50 80 00       	mov    0x805080,%eax
  80142a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801430:	a1 84 50 80 00       	mov    0x805084,%eax
  801435:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801443:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 0c             	sub    $0xc,%esp
  80144e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801451:	8b 55 08             	mov    0x8(%ebp),%edx
  801454:	8b 52 0c             	mov    0xc(%edx),%edx
  801457:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80145d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801462:	50                   	push   %eax
  801463:	ff 75 0c             	pushl  0xc(%ebp)
  801466:	68 08 50 80 00       	push   $0x805008
  80146b:	e8 34 f4 ff ff       	call   8008a4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801470:	ba 00 00 00 00       	mov    $0x0,%edx
  801475:	b8 04 00 00 00       	mov    $0x4,%eax
  80147a:	e8 d9 fe ff ff       	call   801358 <fsipc>

}
  80147f:	c9                   	leave  
  801480:	c3                   	ret    

00801481 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	56                   	push   %esi
  801485:	53                   	push   %ebx
  801486:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801489:	8b 45 08             	mov    0x8(%ebp),%eax
  80148c:	8b 40 0c             	mov    0xc(%eax),%eax
  80148f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801494:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80149a:	ba 00 00 00 00       	mov    $0x0,%edx
  80149f:	b8 03 00 00 00       	mov    $0x3,%eax
  8014a4:	e8 af fe ff ff       	call   801358 <fsipc>
  8014a9:	89 c3                	mov    %eax,%ebx
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 4b                	js     8014fa <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014af:	39 c6                	cmp    %eax,%esi
  8014b1:	73 16                	jae    8014c9 <devfile_read+0x48>
  8014b3:	68 3c 27 80 00       	push   $0x80273c
  8014b8:	68 43 27 80 00       	push   $0x802743
  8014bd:	6a 7c                	push   $0x7c
  8014bf:	68 58 27 80 00       	push   $0x802758
  8014c4:	e8 24 0a 00 00       	call   801eed <_panic>
	assert(r <= PGSIZE);
  8014c9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ce:	7e 16                	jle    8014e6 <devfile_read+0x65>
  8014d0:	68 63 27 80 00       	push   $0x802763
  8014d5:	68 43 27 80 00       	push   $0x802743
  8014da:	6a 7d                	push   $0x7d
  8014dc:	68 58 27 80 00       	push   $0x802758
  8014e1:	e8 07 0a 00 00       	call   801eed <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014e6:	83 ec 04             	sub    $0x4,%esp
  8014e9:	50                   	push   %eax
  8014ea:	68 00 50 80 00       	push   $0x805000
  8014ef:	ff 75 0c             	pushl  0xc(%ebp)
  8014f2:	e8 ad f3 ff ff       	call   8008a4 <memmove>
	return r;
  8014f7:	83 c4 10             	add    $0x10,%esp
}
  8014fa:	89 d8                	mov    %ebx,%eax
  8014fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ff:	5b                   	pop    %ebx
  801500:	5e                   	pop    %esi
  801501:	5d                   	pop    %ebp
  801502:	c3                   	ret    

00801503 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	53                   	push   %ebx
  801507:	83 ec 20             	sub    $0x20,%esp
  80150a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80150d:	53                   	push   %ebx
  80150e:	e8 c6 f1 ff ff       	call   8006d9 <strlen>
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80151b:	7f 67                	jg     801584 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80151d:	83 ec 0c             	sub    $0xc,%esp
  801520:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	e8 a7 f8 ff ff       	call   800dd0 <fd_alloc>
  801529:	83 c4 10             	add    $0x10,%esp
		return r;
  80152c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 57                	js     801589 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	53                   	push   %ebx
  801536:	68 00 50 80 00       	push   $0x805000
  80153b:	e8 d2 f1 ff ff       	call   800712 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801540:	8b 45 0c             	mov    0xc(%ebp),%eax
  801543:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801548:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154b:	b8 01 00 00 00       	mov    $0x1,%eax
  801550:	e8 03 fe ff ff       	call   801358 <fsipc>
  801555:	89 c3                	mov    %eax,%ebx
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	79 14                	jns    801572 <open+0x6f>
		fd_close(fd, 0);
  80155e:	83 ec 08             	sub    $0x8,%esp
  801561:	6a 00                	push   $0x0
  801563:	ff 75 f4             	pushl  -0xc(%ebp)
  801566:	e8 5d f9 ff ff       	call   800ec8 <fd_close>
		return r;
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	89 da                	mov    %ebx,%edx
  801570:	eb 17                	jmp    801589 <open+0x86>
	}

	return fd2num(fd);
  801572:	83 ec 0c             	sub    $0xc,%esp
  801575:	ff 75 f4             	pushl  -0xc(%ebp)
  801578:	e8 2c f8 ff ff       	call   800da9 <fd2num>
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	eb 05                	jmp    801589 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801584:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801589:	89 d0                	mov    %edx,%eax
  80158b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801596:	ba 00 00 00 00       	mov    $0x0,%edx
  80159b:	b8 08 00 00 00       	mov    $0x8,%eax
  8015a0:	e8 b3 fd ff ff       	call   801358 <fsipc>
}
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015ad:	68 6f 27 80 00       	push   $0x80276f
  8015b2:	ff 75 0c             	pushl  0xc(%ebp)
  8015b5:	e8 58 f1 ff ff       	call   800712 <strcpy>
	return 0;
}
  8015ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	53                   	push   %ebx
  8015c5:	83 ec 10             	sub    $0x10,%esp
  8015c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015cb:	53                   	push   %ebx
  8015cc:	e8 56 0a 00 00       	call   802027 <pageref>
  8015d1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015d4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015d9:	83 f8 01             	cmp    $0x1,%eax
  8015dc:	75 10                	jne    8015ee <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	ff 73 0c             	pushl  0xc(%ebx)
  8015e4:	e8 c0 02 00 00       	call   8018a9 <nsipc_close>
  8015e9:	89 c2                	mov    %eax,%edx
  8015eb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015ee:	89 d0                	mov    %edx,%eax
  8015f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015fb:	6a 00                	push   $0x0
  8015fd:	ff 75 10             	pushl  0x10(%ebp)
  801600:	ff 75 0c             	pushl  0xc(%ebp)
  801603:	8b 45 08             	mov    0x8(%ebp),%eax
  801606:	ff 70 0c             	pushl  0xc(%eax)
  801609:	e8 78 03 00 00       	call   801986 <nsipc_send>
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801616:	6a 00                	push   $0x0
  801618:	ff 75 10             	pushl  0x10(%ebp)
  80161b:	ff 75 0c             	pushl  0xc(%ebp)
  80161e:	8b 45 08             	mov    0x8(%ebp),%eax
  801621:	ff 70 0c             	pushl  0xc(%eax)
  801624:	e8 f1 02 00 00       	call   80191a <nsipc_recv>
}
  801629:	c9                   	leave  
  80162a:	c3                   	ret    

0080162b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80162b:	55                   	push   %ebp
  80162c:	89 e5                	mov    %esp,%ebp
  80162e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801631:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801634:	52                   	push   %edx
  801635:	50                   	push   %eax
  801636:	e8 e4 f7 ff ff       	call   800e1f <fd_lookup>
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 17                	js     801659 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801642:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801645:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80164b:	39 08                	cmp    %ecx,(%eax)
  80164d:	75 05                	jne    801654 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80164f:	8b 40 0c             	mov    0xc(%eax),%eax
  801652:	eb 05                	jmp    801659 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801654:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	56                   	push   %esi
  80165f:	53                   	push   %ebx
  801660:	83 ec 1c             	sub    $0x1c,%esp
  801663:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	e8 62 f7 ff ff       	call   800dd0 <fd_alloc>
  80166e:	89 c3                	mov    %eax,%ebx
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	78 1b                	js     801692 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801677:	83 ec 04             	sub    $0x4,%esp
  80167a:	68 07 04 00 00       	push   $0x407
  80167f:	ff 75 f4             	pushl  -0xc(%ebp)
  801682:	6a 00                	push   $0x0
  801684:	e8 8c f4 ff ff       	call   800b15 <sys_page_alloc>
  801689:	89 c3                	mov    %eax,%ebx
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	85 c0                	test   %eax,%eax
  801690:	79 10                	jns    8016a2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	56                   	push   %esi
  801696:	e8 0e 02 00 00       	call   8018a9 <nsipc_close>
		return r;
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	89 d8                	mov    %ebx,%eax
  8016a0:	eb 24                	jmp    8016c6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8016a2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016b7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016ba:	83 ec 0c             	sub    $0xc,%esp
  8016bd:	50                   	push   %eax
  8016be:	e8 e6 f6 ff ff       	call   800da9 <fd2num>
  8016c3:	83 c4 10             	add    $0x10,%esp
}
  8016c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5d                   	pop    %ebp
  8016cc:	c3                   	ret    

008016cd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d6:	e8 50 ff ff ff       	call   80162b <fd2sockid>
		return r;
  8016db:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 1f                	js     801700 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016e1:	83 ec 04             	sub    $0x4,%esp
  8016e4:	ff 75 10             	pushl  0x10(%ebp)
  8016e7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ea:	50                   	push   %eax
  8016eb:	e8 12 01 00 00       	call   801802 <nsipc_accept>
  8016f0:	83 c4 10             	add    $0x10,%esp
		return r;
  8016f3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 07                	js     801700 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016f9:	e8 5d ff ff ff       	call   80165b <alloc_sockfd>
  8016fe:	89 c1                	mov    %eax,%ecx
}
  801700:	89 c8                	mov    %ecx,%eax
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80170a:	8b 45 08             	mov    0x8(%ebp),%eax
  80170d:	e8 19 ff ff ff       	call   80162b <fd2sockid>
  801712:	85 c0                	test   %eax,%eax
  801714:	78 12                	js     801728 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801716:	83 ec 04             	sub    $0x4,%esp
  801719:	ff 75 10             	pushl  0x10(%ebp)
  80171c:	ff 75 0c             	pushl  0xc(%ebp)
  80171f:	50                   	push   %eax
  801720:	e8 2d 01 00 00       	call   801852 <nsipc_bind>
  801725:	83 c4 10             	add    $0x10,%esp
}
  801728:	c9                   	leave  
  801729:	c3                   	ret    

0080172a <shutdown>:

int
shutdown(int s, int how)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801730:	8b 45 08             	mov    0x8(%ebp),%eax
  801733:	e8 f3 fe ff ff       	call   80162b <fd2sockid>
  801738:	85 c0                	test   %eax,%eax
  80173a:	78 0f                	js     80174b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80173c:	83 ec 08             	sub    $0x8,%esp
  80173f:	ff 75 0c             	pushl  0xc(%ebp)
  801742:	50                   	push   %eax
  801743:	e8 3f 01 00 00       	call   801887 <nsipc_shutdown>
  801748:	83 c4 10             	add    $0x10,%esp
}
  80174b:	c9                   	leave  
  80174c:	c3                   	ret    

0080174d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801753:	8b 45 08             	mov    0x8(%ebp),%eax
  801756:	e8 d0 fe ff ff       	call   80162b <fd2sockid>
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 12                	js     801771 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80175f:	83 ec 04             	sub    $0x4,%esp
  801762:	ff 75 10             	pushl  0x10(%ebp)
  801765:	ff 75 0c             	pushl  0xc(%ebp)
  801768:	50                   	push   %eax
  801769:	e8 55 01 00 00       	call   8018c3 <nsipc_connect>
  80176e:	83 c4 10             	add    $0x10,%esp
}
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <listen>:

int
listen(int s, int backlog)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801779:	8b 45 08             	mov    0x8(%ebp),%eax
  80177c:	e8 aa fe ff ff       	call   80162b <fd2sockid>
  801781:	85 c0                	test   %eax,%eax
  801783:	78 0f                	js     801794 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801785:	83 ec 08             	sub    $0x8,%esp
  801788:	ff 75 0c             	pushl  0xc(%ebp)
  80178b:	50                   	push   %eax
  80178c:	e8 67 01 00 00       	call   8018f8 <nsipc_listen>
  801791:	83 c4 10             	add    $0x10,%esp
}
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80179c:	ff 75 10             	pushl  0x10(%ebp)
  80179f:	ff 75 0c             	pushl  0xc(%ebp)
  8017a2:	ff 75 08             	pushl  0x8(%ebp)
  8017a5:	e8 3a 02 00 00       	call   8019e4 <nsipc_socket>
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 05                	js     8017b6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8017b1:	e8 a5 fe ff ff       	call   80165b <alloc_sockfd>
}
  8017b6:	c9                   	leave  
  8017b7:	c3                   	ret    

008017b8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	53                   	push   %ebx
  8017bc:	83 ec 04             	sub    $0x4,%esp
  8017bf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017c1:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017c8:	75 12                	jne    8017dc <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017ca:	83 ec 0c             	sub    $0xc,%esp
  8017cd:	6a 02                	push   $0x2
  8017cf:	e8 1a 08 00 00       	call   801fee <ipc_find_env>
  8017d4:	a3 04 40 80 00       	mov    %eax,0x804004
  8017d9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017dc:	6a 07                	push   $0x7
  8017de:	68 00 60 80 00       	push   $0x806000
  8017e3:	53                   	push   %ebx
  8017e4:	ff 35 04 40 80 00    	pushl  0x804004
  8017ea:	e8 ab 07 00 00       	call   801f9a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017ef:	83 c4 0c             	add    $0xc,%esp
  8017f2:	6a 00                	push   $0x0
  8017f4:	6a 00                	push   $0x0
  8017f6:	6a 00                	push   $0x0
  8017f8:	e8 36 07 00 00       	call   801f33 <ipc_recv>
}
  8017fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801800:	c9                   	leave  
  801801:	c3                   	ret    

00801802 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	56                   	push   %esi
  801806:	53                   	push   %ebx
  801807:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801812:	8b 06                	mov    (%esi),%eax
  801814:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801819:	b8 01 00 00 00       	mov    $0x1,%eax
  80181e:	e8 95 ff ff ff       	call   8017b8 <nsipc>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	85 c0                	test   %eax,%eax
  801827:	78 20                	js     801849 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801829:	83 ec 04             	sub    $0x4,%esp
  80182c:	ff 35 10 60 80 00    	pushl  0x806010
  801832:	68 00 60 80 00       	push   $0x806000
  801837:	ff 75 0c             	pushl  0xc(%ebp)
  80183a:	e8 65 f0 ff ff       	call   8008a4 <memmove>
		*addrlen = ret->ret_addrlen;
  80183f:	a1 10 60 80 00       	mov    0x806010,%eax
  801844:	89 06                	mov    %eax,(%esi)
  801846:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801849:	89 d8                	mov    %ebx,%eax
  80184b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184e:	5b                   	pop    %ebx
  80184f:	5e                   	pop    %esi
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    

00801852 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	53                   	push   %ebx
  801856:	83 ec 08             	sub    $0x8,%esp
  801859:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801864:	53                   	push   %ebx
  801865:	ff 75 0c             	pushl  0xc(%ebp)
  801868:	68 04 60 80 00       	push   $0x806004
  80186d:	e8 32 f0 ff ff       	call   8008a4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801872:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801878:	b8 02 00 00 00       	mov    $0x2,%eax
  80187d:	e8 36 ff ff ff       	call   8017b8 <nsipc>
}
  801882:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801885:	c9                   	leave  
  801886:	c3                   	ret    

00801887 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80188d:	8b 45 08             	mov    0x8(%ebp),%eax
  801890:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801895:	8b 45 0c             	mov    0xc(%ebp),%eax
  801898:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80189d:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a2:	e8 11 ff ff ff       	call   8017b8 <nsipc>
}
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    

008018a9 <nsipc_close>:

int
nsipc_close(int s)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018b7:	b8 04 00 00 00       	mov    $0x4,%eax
  8018bc:	e8 f7 fe ff ff       	call   8017b8 <nsipc>
}
  8018c1:	c9                   	leave  
  8018c2:	c3                   	ret    

008018c3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	53                   	push   %ebx
  8018c7:	83 ec 08             	sub    $0x8,%esp
  8018ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018d5:	53                   	push   %ebx
  8018d6:	ff 75 0c             	pushl  0xc(%ebp)
  8018d9:	68 04 60 80 00       	push   $0x806004
  8018de:	e8 c1 ef ff ff       	call   8008a4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018e3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ee:	e8 c5 fe ff ff       	call   8017b8 <nsipc>
}
  8018f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801906:	8b 45 0c             	mov    0xc(%ebp),%eax
  801909:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80190e:	b8 06 00 00 00       	mov    $0x6,%eax
  801913:	e8 a0 fe ff ff       	call   8017b8 <nsipc>
}
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	56                   	push   %esi
  80191e:	53                   	push   %ebx
  80191f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
  801925:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80192a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801930:	8b 45 14             	mov    0x14(%ebp),%eax
  801933:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801938:	b8 07 00 00 00       	mov    $0x7,%eax
  80193d:	e8 76 fe ff ff       	call   8017b8 <nsipc>
  801942:	89 c3                	mov    %eax,%ebx
  801944:	85 c0                	test   %eax,%eax
  801946:	78 35                	js     80197d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801948:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80194d:	7f 04                	jg     801953 <nsipc_recv+0x39>
  80194f:	39 c6                	cmp    %eax,%esi
  801951:	7d 16                	jge    801969 <nsipc_recv+0x4f>
  801953:	68 7b 27 80 00       	push   $0x80277b
  801958:	68 43 27 80 00       	push   $0x802743
  80195d:	6a 62                	push   $0x62
  80195f:	68 90 27 80 00       	push   $0x802790
  801964:	e8 84 05 00 00       	call   801eed <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801969:	83 ec 04             	sub    $0x4,%esp
  80196c:	50                   	push   %eax
  80196d:	68 00 60 80 00       	push   $0x806000
  801972:	ff 75 0c             	pushl  0xc(%ebp)
  801975:	e8 2a ef ff ff       	call   8008a4 <memmove>
  80197a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80197d:	89 d8                	mov    %ebx,%eax
  80197f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801982:	5b                   	pop    %ebx
  801983:	5e                   	pop    %esi
  801984:	5d                   	pop    %ebp
  801985:	c3                   	ret    

00801986 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	53                   	push   %ebx
  80198a:	83 ec 04             	sub    $0x4,%esp
  80198d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801990:	8b 45 08             	mov    0x8(%ebp),%eax
  801993:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801998:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80199e:	7e 16                	jle    8019b6 <nsipc_send+0x30>
  8019a0:	68 9c 27 80 00       	push   $0x80279c
  8019a5:	68 43 27 80 00       	push   $0x802743
  8019aa:	6a 6d                	push   $0x6d
  8019ac:	68 90 27 80 00       	push   $0x802790
  8019b1:	e8 37 05 00 00       	call   801eed <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019b6:	83 ec 04             	sub    $0x4,%esp
  8019b9:	53                   	push   %ebx
  8019ba:	ff 75 0c             	pushl  0xc(%ebp)
  8019bd:	68 0c 60 80 00       	push   $0x80600c
  8019c2:	e8 dd ee ff ff       	call   8008a4 <memmove>
	nsipcbuf.send.req_size = size;
  8019c7:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019d5:	b8 08 00 00 00       	mov    $0x8,%eax
  8019da:	e8 d9 fd ff ff       	call   8017b8 <nsipc>
}
  8019df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ed:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f5:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8019fd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a02:	b8 09 00 00 00       	mov    $0x9,%eax
  801a07:	e8 ac fd ff ff       	call   8017b8 <nsipc>
}
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	56                   	push   %esi
  801a12:	53                   	push   %ebx
  801a13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	ff 75 08             	pushl  0x8(%ebp)
  801a1c:	e8 98 f3 ff ff       	call   800db9 <fd2data>
  801a21:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a23:	83 c4 08             	add    $0x8,%esp
  801a26:	68 a8 27 80 00       	push   $0x8027a8
  801a2b:	53                   	push   %ebx
  801a2c:	e8 e1 ec ff ff       	call   800712 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a31:	8b 46 04             	mov    0x4(%esi),%eax
  801a34:	2b 06                	sub    (%esi),%eax
  801a36:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a3c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a43:	00 00 00 
	stat->st_dev = &devpipe;
  801a46:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a4d:	30 80 00 
	return 0;
}
  801a50:	b8 00 00 00 00       	mov    $0x0,%eax
  801a55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	53                   	push   %ebx
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a66:	53                   	push   %ebx
  801a67:	6a 00                	push   $0x0
  801a69:	e8 2c f1 ff ff       	call   800b9a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a6e:	89 1c 24             	mov    %ebx,(%esp)
  801a71:	e8 43 f3 ff ff       	call   800db9 <fd2data>
  801a76:	83 c4 08             	add    $0x8,%esp
  801a79:	50                   	push   %eax
  801a7a:	6a 00                	push   $0x0
  801a7c:	e8 19 f1 ff ff       	call   800b9a <sys_page_unmap>
}
  801a81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	57                   	push   %edi
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 1c             	sub    $0x1c,%esp
  801a8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a92:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a94:	a1 08 40 80 00       	mov    0x804008,%eax
  801a99:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	ff 75 e0             	pushl  -0x20(%ebp)
  801aa2:	e8 80 05 00 00       	call   802027 <pageref>
  801aa7:	89 c3                	mov    %eax,%ebx
  801aa9:	89 3c 24             	mov    %edi,(%esp)
  801aac:	e8 76 05 00 00       	call   802027 <pageref>
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	39 c3                	cmp    %eax,%ebx
  801ab6:	0f 94 c1             	sete   %cl
  801ab9:	0f b6 c9             	movzbl %cl,%ecx
  801abc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801abf:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ac5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ac8:	39 ce                	cmp    %ecx,%esi
  801aca:	74 1b                	je     801ae7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801acc:	39 c3                	cmp    %eax,%ebx
  801ace:	75 c4                	jne    801a94 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ad0:	8b 42 58             	mov    0x58(%edx),%eax
  801ad3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ad6:	50                   	push   %eax
  801ad7:	56                   	push   %esi
  801ad8:	68 af 27 80 00       	push   $0x8027af
  801add:	e8 ab e6 ff ff       	call   80018d <cprintf>
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	eb ad                	jmp    801a94 <_pipeisclosed+0xe>
	}
}
  801ae7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5f                   	pop    %edi
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	57                   	push   %edi
  801af6:	56                   	push   %esi
  801af7:	53                   	push   %ebx
  801af8:	83 ec 28             	sub    $0x28,%esp
  801afb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801afe:	56                   	push   %esi
  801aff:	e8 b5 f2 ff ff       	call   800db9 <fd2data>
  801b04:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	bf 00 00 00 00       	mov    $0x0,%edi
  801b0e:	eb 4b                	jmp    801b5b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b10:	89 da                	mov    %ebx,%edx
  801b12:	89 f0                	mov    %esi,%eax
  801b14:	e8 6d ff ff ff       	call   801a86 <_pipeisclosed>
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	75 48                	jne    801b65 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b1d:	e8 d4 ef ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b22:	8b 43 04             	mov    0x4(%ebx),%eax
  801b25:	8b 0b                	mov    (%ebx),%ecx
  801b27:	8d 51 20             	lea    0x20(%ecx),%edx
  801b2a:	39 d0                	cmp    %edx,%eax
  801b2c:	73 e2                	jae    801b10 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b31:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b35:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b38:	89 c2                	mov    %eax,%edx
  801b3a:	c1 fa 1f             	sar    $0x1f,%edx
  801b3d:	89 d1                	mov    %edx,%ecx
  801b3f:	c1 e9 1b             	shr    $0x1b,%ecx
  801b42:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b45:	83 e2 1f             	and    $0x1f,%edx
  801b48:	29 ca                	sub    %ecx,%edx
  801b4a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b4e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b52:	83 c0 01             	add    $0x1,%eax
  801b55:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b58:	83 c7 01             	add    $0x1,%edi
  801b5b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b5e:	75 c2                	jne    801b22 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b60:	8b 45 10             	mov    0x10(%ebp),%eax
  801b63:	eb 05                	jmp    801b6a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6d:	5b                   	pop    %ebx
  801b6e:	5e                   	pop    %esi
  801b6f:	5f                   	pop    %edi
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	57                   	push   %edi
  801b76:	56                   	push   %esi
  801b77:	53                   	push   %ebx
  801b78:	83 ec 18             	sub    $0x18,%esp
  801b7b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b7e:	57                   	push   %edi
  801b7f:	e8 35 f2 ff ff       	call   800db9 <fd2data>
  801b84:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b8e:	eb 3d                	jmp    801bcd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b90:	85 db                	test   %ebx,%ebx
  801b92:	74 04                	je     801b98 <devpipe_read+0x26>
				return i;
  801b94:	89 d8                	mov    %ebx,%eax
  801b96:	eb 44                	jmp    801bdc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b98:	89 f2                	mov    %esi,%edx
  801b9a:	89 f8                	mov    %edi,%eax
  801b9c:	e8 e5 fe ff ff       	call   801a86 <_pipeisclosed>
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	75 32                	jne    801bd7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ba5:	e8 4c ef ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801baa:	8b 06                	mov    (%esi),%eax
  801bac:	3b 46 04             	cmp    0x4(%esi),%eax
  801baf:	74 df                	je     801b90 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bb1:	99                   	cltd   
  801bb2:	c1 ea 1b             	shr    $0x1b,%edx
  801bb5:	01 d0                	add    %edx,%eax
  801bb7:	83 e0 1f             	and    $0x1f,%eax
  801bba:	29 d0                	sub    %edx,%eax
  801bbc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bc7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bca:	83 c3 01             	add    $0x1,%ebx
  801bcd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bd0:	75 d8                	jne    801baa <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bd2:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd5:	eb 05                	jmp    801bdc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bd7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdf:	5b                   	pop    %ebx
  801be0:	5e                   	pop    %esi
  801be1:	5f                   	pop    %edi
  801be2:	5d                   	pop    %ebp
  801be3:	c3                   	ret    

00801be4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bef:	50                   	push   %eax
  801bf0:	e8 db f1 ff ff       	call   800dd0 <fd_alloc>
  801bf5:	83 c4 10             	add    $0x10,%esp
  801bf8:	89 c2                	mov    %eax,%edx
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	0f 88 2c 01 00 00    	js     801d2e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c02:	83 ec 04             	sub    $0x4,%esp
  801c05:	68 07 04 00 00       	push   $0x407
  801c0a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0d:	6a 00                	push   $0x0
  801c0f:	e8 01 ef ff ff       	call   800b15 <sys_page_alloc>
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	89 c2                	mov    %eax,%edx
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	0f 88 0d 01 00 00    	js     801d2e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c21:	83 ec 0c             	sub    $0xc,%esp
  801c24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c27:	50                   	push   %eax
  801c28:	e8 a3 f1 ff ff       	call   800dd0 <fd_alloc>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	85 c0                	test   %eax,%eax
  801c34:	0f 88 e2 00 00 00    	js     801d1c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3a:	83 ec 04             	sub    $0x4,%esp
  801c3d:	68 07 04 00 00       	push   $0x407
  801c42:	ff 75 f0             	pushl  -0x10(%ebp)
  801c45:	6a 00                	push   $0x0
  801c47:	e8 c9 ee ff ff       	call   800b15 <sys_page_alloc>
  801c4c:	89 c3                	mov    %eax,%ebx
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	85 c0                	test   %eax,%eax
  801c53:	0f 88 c3 00 00 00    	js     801d1c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c59:	83 ec 0c             	sub    $0xc,%esp
  801c5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5f:	e8 55 f1 ff ff       	call   800db9 <fd2data>
  801c64:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c66:	83 c4 0c             	add    $0xc,%esp
  801c69:	68 07 04 00 00       	push   $0x407
  801c6e:	50                   	push   %eax
  801c6f:	6a 00                	push   $0x0
  801c71:	e8 9f ee ff ff       	call   800b15 <sys_page_alloc>
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	0f 88 89 00 00 00    	js     801d0c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c83:	83 ec 0c             	sub    $0xc,%esp
  801c86:	ff 75 f0             	pushl  -0x10(%ebp)
  801c89:	e8 2b f1 ff ff       	call   800db9 <fd2data>
  801c8e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c95:	50                   	push   %eax
  801c96:	6a 00                	push   $0x0
  801c98:	56                   	push   %esi
  801c99:	6a 00                	push   $0x0
  801c9b:	e8 b8 ee ff ff       	call   800b58 <sys_page_map>
  801ca0:	89 c3                	mov    %eax,%ebx
  801ca2:	83 c4 20             	add    $0x20,%esp
  801ca5:	85 c0                	test   %eax,%eax
  801ca7:	78 55                	js     801cfe <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ca9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cbe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ccc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cd3:	83 ec 0c             	sub    $0xc,%esp
  801cd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd9:	e8 cb f0 ff ff       	call   800da9 <fd2num>
  801cde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ce3:	83 c4 04             	add    $0x4,%esp
  801ce6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce9:	e8 bb f0 ff ff       	call   800da9 <fd2num>
  801cee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cfc:	eb 30                	jmp    801d2e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cfe:	83 ec 08             	sub    $0x8,%esp
  801d01:	56                   	push   %esi
  801d02:	6a 00                	push   $0x0
  801d04:	e8 91 ee ff ff       	call   800b9a <sys_page_unmap>
  801d09:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d0c:	83 ec 08             	sub    $0x8,%esp
  801d0f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d12:	6a 00                	push   $0x0
  801d14:	e8 81 ee ff ff       	call   800b9a <sys_page_unmap>
  801d19:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d1c:	83 ec 08             	sub    $0x8,%esp
  801d1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d22:	6a 00                	push   $0x0
  801d24:	e8 71 ee ff ff       	call   800b9a <sys_page_unmap>
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d2e:	89 d0                	mov    %edx,%eax
  801d30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    

00801d37 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d40:	50                   	push   %eax
  801d41:	ff 75 08             	pushl  0x8(%ebp)
  801d44:	e8 d6 f0 ff ff       	call   800e1f <fd_lookup>
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	78 18                	js     801d68 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d50:	83 ec 0c             	sub    $0xc,%esp
  801d53:	ff 75 f4             	pushl  -0xc(%ebp)
  801d56:	e8 5e f0 ff ff       	call   800db9 <fd2data>
	return _pipeisclosed(fd, p);
  801d5b:	89 c2                	mov    %eax,%edx
  801d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d60:	e8 21 fd ff ff       	call   801a86 <_pipeisclosed>
  801d65:	83 c4 10             	add    $0x10,%esp
}
  801d68:	c9                   	leave  
  801d69:	c3                   	ret    

00801d6a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    

00801d74 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d7a:	68 c7 27 80 00       	push   $0x8027c7
  801d7f:	ff 75 0c             	pushl  0xc(%ebp)
  801d82:	e8 8b e9 ff ff       	call   800712 <strcpy>
	return 0;
}
  801d87:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d9a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d9f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da5:	eb 2d                	jmp    801dd4 <devcons_write+0x46>
		m = n - tot;
  801da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801daa:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dac:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801daf:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801db4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db7:	83 ec 04             	sub    $0x4,%esp
  801dba:	53                   	push   %ebx
  801dbb:	03 45 0c             	add    0xc(%ebp),%eax
  801dbe:	50                   	push   %eax
  801dbf:	57                   	push   %edi
  801dc0:	e8 df ea ff ff       	call   8008a4 <memmove>
		sys_cputs(buf, m);
  801dc5:	83 c4 08             	add    $0x8,%esp
  801dc8:	53                   	push   %ebx
  801dc9:	57                   	push   %edi
  801dca:	e8 8a ec ff ff       	call   800a59 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dcf:	01 de                	add    %ebx,%esi
  801dd1:	83 c4 10             	add    $0x10,%esp
  801dd4:	89 f0                	mov    %esi,%eax
  801dd6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dd9:	72 cc                	jb     801da7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ddb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dde:	5b                   	pop    %ebx
  801ddf:	5e                   	pop    %esi
  801de0:	5f                   	pop    %edi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    

00801de3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	83 ec 08             	sub    $0x8,%esp
  801de9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801df2:	74 2a                	je     801e1e <devcons_read+0x3b>
  801df4:	eb 05                	jmp    801dfb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801df6:	e8 fb ec ff ff       	call   800af6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dfb:	e8 77 ec ff ff       	call   800a77 <sys_cgetc>
  801e00:	85 c0                	test   %eax,%eax
  801e02:	74 f2                	je     801df6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e04:	85 c0                	test   %eax,%eax
  801e06:	78 16                	js     801e1e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e08:	83 f8 04             	cmp    $0x4,%eax
  801e0b:	74 0c                	je     801e19 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e10:	88 02                	mov    %al,(%edx)
	return 1;
  801e12:	b8 01 00 00 00       	mov    $0x1,%eax
  801e17:	eb 05                	jmp    801e1e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e19:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e26:	8b 45 08             	mov    0x8(%ebp),%eax
  801e29:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e2c:	6a 01                	push   $0x1
  801e2e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e31:	50                   	push   %eax
  801e32:	e8 22 ec ff ff       	call   800a59 <sys_cputs>
}
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	c9                   	leave  
  801e3b:	c3                   	ret    

00801e3c <getchar>:

int
getchar(void)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e42:	6a 01                	push   $0x1
  801e44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	6a 00                	push   $0x0
  801e4a:	e8 36 f2 ff ff       	call   801085 <read>
	if (r < 0)
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	78 0f                	js     801e65 <getchar+0x29>
		return r;
	if (r < 1)
  801e56:	85 c0                	test   %eax,%eax
  801e58:	7e 06                	jle    801e60 <getchar+0x24>
		return -E_EOF;
	return c;
  801e5a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e5e:	eb 05                	jmp    801e65 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e60:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e70:	50                   	push   %eax
  801e71:	ff 75 08             	pushl  0x8(%ebp)
  801e74:	e8 a6 ef ff ff       	call   800e1f <fd_lookup>
  801e79:	83 c4 10             	add    $0x10,%esp
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	78 11                	js     801e91 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e83:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e89:	39 10                	cmp    %edx,(%eax)
  801e8b:	0f 94 c0             	sete   %al
  801e8e:	0f b6 c0             	movzbl %al,%eax
}
  801e91:	c9                   	leave  
  801e92:	c3                   	ret    

00801e93 <opencons>:

int
opencons(void)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9c:	50                   	push   %eax
  801e9d:	e8 2e ef ff ff       	call   800dd0 <fd_alloc>
  801ea2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ea5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	78 3e                	js     801ee9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eab:	83 ec 04             	sub    $0x4,%esp
  801eae:	68 07 04 00 00       	push   $0x407
  801eb3:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb6:	6a 00                	push   $0x0
  801eb8:	e8 58 ec ff ff       	call   800b15 <sys_page_alloc>
  801ebd:	83 c4 10             	add    $0x10,%esp
		return r;
  801ec0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	78 23                	js     801ee9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ec6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801edb:	83 ec 0c             	sub    $0xc,%esp
  801ede:	50                   	push   %eax
  801edf:	e8 c5 ee ff ff       	call   800da9 <fd2num>
  801ee4:	89 c2                	mov    %eax,%edx
  801ee6:	83 c4 10             	add    $0x10,%esp
}
  801ee9:	89 d0                	mov    %edx,%eax
  801eeb:	c9                   	leave  
  801eec:	c3                   	ret    

00801eed <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	56                   	push   %esi
  801ef1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ef2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ef5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801efb:	e8 d7 eb ff ff       	call   800ad7 <sys_getenvid>
  801f00:	83 ec 0c             	sub    $0xc,%esp
  801f03:	ff 75 0c             	pushl  0xc(%ebp)
  801f06:	ff 75 08             	pushl  0x8(%ebp)
  801f09:	56                   	push   %esi
  801f0a:	50                   	push   %eax
  801f0b:	68 d4 27 80 00       	push   $0x8027d4
  801f10:	e8 78 e2 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f15:	83 c4 18             	add    $0x18,%esp
  801f18:	53                   	push   %ebx
  801f19:	ff 75 10             	pushl  0x10(%ebp)
  801f1c:	e8 1b e2 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801f21:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  801f28:	e8 60 e2 ff ff       	call   80018d <cprintf>
  801f2d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f30:	cc                   	int3   
  801f31:	eb fd                	jmp    801f30 <_panic+0x43>

00801f33 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
  801f38:	8b 75 08             	mov    0x8(%ebp),%esi
  801f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801f41:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801f43:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f48:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801f4b:	83 ec 0c             	sub    $0xc,%esp
  801f4e:	50                   	push   %eax
  801f4f:	e8 71 ed ff ff       	call   800cc5 <sys_ipc_recv>

	if (from_env_store != NULL)
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	85 f6                	test   %esi,%esi
  801f59:	74 14                	je     801f6f <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801f5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 09                	js     801f6d <ipc_recv+0x3a>
  801f64:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f6a:	8b 52 74             	mov    0x74(%edx),%edx
  801f6d:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801f6f:	85 db                	test   %ebx,%ebx
  801f71:	74 14                	je     801f87 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801f73:	ba 00 00 00 00       	mov    $0x0,%edx
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	78 09                	js     801f85 <ipc_recv+0x52>
  801f7c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f82:	8b 52 78             	mov    0x78(%edx),%edx
  801f85:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801f87:	85 c0                	test   %eax,%eax
  801f89:	78 08                	js     801f93 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801f8b:	a1 08 40 80 00       	mov    0x804008,%eax
  801f90:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f96:	5b                   	pop    %ebx
  801f97:	5e                   	pop    %esi
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	57                   	push   %edi
  801f9e:	56                   	push   %esi
  801f9f:	53                   	push   %ebx
  801fa0:	83 ec 0c             	sub    $0xc,%esp
  801fa3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801fac:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801fae:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fb3:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801fb6:	ff 75 14             	pushl  0x14(%ebp)
  801fb9:	53                   	push   %ebx
  801fba:	56                   	push   %esi
  801fbb:	57                   	push   %edi
  801fbc:	e8 e1 ec ff ff       	call   800ca2 <sys_ipc_try_send>

		if (err < 0) {
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	79 1e                	jns    801fe6 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801fc8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fcb:	75 07                	jne    801fd4 <ipc_send+0x3a>
				sys_yield();
  801fcd:	e8 24 eb ff ff       	call   800af6 <sys_yield>
  801fd2:	eb e2                	jmp    801fb6 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801fd4:	50                   	push   %eax
  801fd5:	68 f8 27 80 00       	push   $0x8027f8
  801fda:	6a 49                	push   $0x49
  801fdc:	68 05 28 80 00       	push   $0x802805
  801fe1:	e8 07 ff ff ff       	call   801eed <_panic>
		}

	} while (err < 0);

}
  801fe6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe9:	5b                   	pop    %ebx
  801fea:	5e                   	pop    %esi
  801feb:	5f                   	pop    %edi
  801fec:	5d                   	pop    %ebp
  801fed:	c3                   	ret    

00801fee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ff4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ff9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ffc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802002:	8b 52 50             	mov    0x50(%edx),%edx
  802005:	39 ca                	cmp    %ecx,%edx
  802007:	75 0d                	jne    802016 <ipc_find_env+0x28>
			return envs[i].env_id;
  802009:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80200c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802011:	8b 40 48             	mov    0x48(%eax),%eax
  802014:	eb 0f                	jmp    802025 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802016:	83 c0 01             	add    $0x1,%eax
  802019:	3d 00 04 00 00       	cmp    $0x400,%eax
  80201e:	75 d9                	jne    801ff9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802020:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    

00802027 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802027:	55                   	push   %ebp
  802028:	89 e5                	mov    %esp,%ebp
  80202a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202d:	89 d0                	mov    %edx,%eax
  80202f:	c1 e8 16             	shr    $0x16,%eax
  802032:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802039:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203e:	f6 c1 01             	test   $0x1,%cl
  802041:	74 1d                	je     802060 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802043:	c1 ea 0c             	shr    $0xc,%edx
  802046:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80204d:	f6 c2 01             	test   $0x1,%dl
  802050:	74 0e                	je     802060 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802052:	c1 ea 0c             	shr    $0xc,%edx
  802055:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80205c:	ef 
  80205d:	0f b7 c0             	movzwl %ax,%eax
}
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	66 90                	xchg   %ax,%ax
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

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
